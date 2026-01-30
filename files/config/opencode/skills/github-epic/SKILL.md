---
name: github-epic
description: Create parent/epic GitHub issues with proper structure and when to create issues
license: MIT
compatibility: opencode
---

## What I do

- Help you create parent/epic issues that define problems and outcomes
- Provide the proper structure and format for epic issues
- Guide you on when to create issues vs when to just code

## When to use me

Use this skill when:
- Starting a new feature or significant change
- Planning work that spans multiple sessions
- Work involves multiple related tasks
- Need to track progress over time
- Collaborating with others on the project

**Always create epic first**, then create child issues linked to it.

---

## Parent Issues (Epic Level)

Parent issues define the **problem** and **desired outcome**, not the implementation path.

### Include:

- ✅ Clear problem statement or user/developer need
- ✅ Why this matters (impact, pain points)
- ✅ Solution approach (high-level strategy)
- ✅ Success criteria (how we measure completion)

### Exclude:

- ❌ List of child issues or tasks
- ❌ Implementation steps or instructions
- ❌ Specific file paths or technical details
- ❌ Anything that belongs in task-level issues

### Why This Approach:

- **Clarity**: Focus on outcomes, not prescriptive steps
- **Flexibility**: Developers can choose implementation approach
- **Context**: Clear connection between tasks and epic goals
- **Trust**: Respects developer expertise to determine "how"

---

## Epic Template

```markdown
# [EPIC] Fix memory leaks in media preview

## Problem

Users report browser slowdowns when scheduling posts with multiple images. Profiling shows media preview components aren't cleaning up properly, causing memory to accumulate during long sessions.

## Solution Approach

Audit and fix component lifecycle issues, implement proper cleanup patterns, and add monitoring to prevent regression.

## Impact

- Stable browser performance during extended sessions
- Reduced support tickets about slowdowns
- Better user experience when working with media-heavy posts

## Success Criteria

- Memory profiling shows no accumulation after 50+ preview loads
- Browser performance metrics remain stable over 30-minute sessions
- No memory-related support tickets in first month post-deployment
```

---

## Create Epic Issue

```bash
gh issue create \
  --title "[EPIC] Feature Name" \
  --body "## Problem
...

## Solution Approach
...

## Impact
...

## Success Criteria
..."
```

After creating the epic, use the `github-task` skill to create and link child issues.
