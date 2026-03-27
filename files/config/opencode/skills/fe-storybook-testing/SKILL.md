---
name: fe-storybook-testing
description: Write Storybook stories as the canonical source of component fixtures and use portable stories to share them with unit tests. Use when creating or updating Storybook stories, writing component tests, or mocking component states.
license: MIT
compatibility: opencode
---

## What I do

- Guide you on writing Storybook stories as the single source of truth for component mock data and visual states
- Show you how to use portable stories (`composeStories`) so tests reuse story fixtures instead of duplicating them
- Establish file conventions for stories and portable story tests

## When to use me

Use this skill when:

- Creating or updating Storybook stories for a component
- Writing or updating unit/integration tests for a component that has (or should have) stories
- Deciding how to mock component props, state, or data for testing
- Reviewing whether a component's test coverage approach follows team conventions

---

## Core principle

**Storybook stories are the first-class way to define component states and mock data.** Tests consume stories rather than maintaining their own separate fixtures. This eliminates duplication and keeps visual documentation and test coverage in sync.

---

## File conventions

| Type | Location | Naming |
|---|---|---|
| Stories | `static/js/stories/<ComponentName>.stories.tsx` | CSF3 format |
| Portable story tests | `static/test/spec/**/<ComponentName>.portable-stories.test.tsx` | Jasmine + RTL |
| Traditional unit tests | `static/test/spec/**/<ComponentName>.test.tsx` | Only when portable stories aren't applicable |

---

## Writing stories

Stories define every meaningful state of a component using real (or realistic) mock data. Each named export is one state.

```tsx
import { useState } from 'react';
import { Button } from 'foundations-components/transitional/components/Button';
import MyComponent from '../components/MyComponent';

export default {
  title: 'my-package/MyComponent',
  parameters: {
    layout: 'centered',
    tags: ['modal', 'feature-name'],
  },
};

// Wrap interactive components (modals, popovers, etc.) in a story function
// that manages open/close state so Storybook can render them.
function DefaultStory() {
  const [open, setOpen] = useState(false);
  return (
    <>
      <Button onClick={() => setOpen(true)}>Open</Button>
      {open && <MyComponent onClose={() => setOpen(false)} data={mockData} />}
    </>
  );
}

export const Default = {
  name: 'Default',
  render: () => <DefaultStory />,
};

// Add a named export for each meaningful variant
export const ErrorState = {
  name: 'Error State',
  render: () => <ErrorStateStory />,
};
```

Key points:
- Use CSF3 (Component Story Format 3) with object exports
- Keep mock data inline or in a shared `__fixtures__` file if multiple stories/tests need it
- Every user-facing state should have a story: happy path, error states, empty states, loading, edge cases

---

## Writing portable story tests

Portable stories let you import Storybook stories directly into unit tests via `composeStories`. This avoids duplicating mock data between stories and tests.

Reference: https://storybook.js.org/docs/writing-tests/integrations/stories-in-unit-tests

```tsx
import { screen, render, cleanup } from 'hs-test-utils/testing-library';
import { getUserEventSession } from 'hs-test-utils/testing-library';
import { composeStories } from '@storybook/react';
import * as stories from '../../../js/stories/MyComponent.stories';

const { Default, ErrorState } = composeStories(stories);

describe('MyComponent (portable stories)', () => {
  afterEach(() => {
    cleanup();
  });

  it('renders Default story with expected content', () => {
    render(<Default />);
    // Assert against the rendered story - no need to rebuild mock data
    expect(screen.getByRole('heading')).toHaveTextContent('Expected Title');
  });

  it('renders ErrorState story with error messaging', () => {
    render(<ErrorState />);
    expect(screen.getByText(/something went wrong/i)).toBeTruthy();
  });
});
```

Key points:
- Import from `@storybook/react` for `composeStories`
- Each composed story is a renderable React component with all its mock data baked in
- Tests focus on **assertions about rendered output**, not on rebuilding fixtures
- Use RTL accessible queries (`ByRole`, `ByText`) per existing HubSpot conventions
- Use `getUserEventSession()` for interactions (clicks, typing, etc.)
- Extract shared interaction helpers (e.g., `openModal()`) when multiple tests need the same setup

---

## When to use portable stories vs traditional tests

| Scenario | Approach |
|---|---|
| Component has visual states worth documenting | Stories + portable story tests |
| Testing component rendering and user interactions | Portable story tests (preferred) |
| Testing pure logic, hooks, or utilities | Traditional unit tests |
| Testing API integration with MSW | Either approach works; portable stories if the story already sets up the mock |
| Component has no stories yet | Write the stories first, then portable story tests |

---

## Workflow

1. **Stories first**: When adding or modifying a component, write/update Storybook stories before writing tests
2. **Portable story tests second**: Write tests that consume stories via `composeStories`
3. **Traditional tests only when needed**: For logic that doesn't map to a visual component state
