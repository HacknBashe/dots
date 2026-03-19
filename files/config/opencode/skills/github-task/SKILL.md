---
name: github-task
description: Create child/task GitHub issues and link them to parent epics using GraphQL
license: MIT
compatibility: opencode
---

## What I do

- Help you create child/task issues that define specific work
- Link child issues to parent epics using GitHub's GraphQL API
- Provide proper task structure and linking commands

## When to use me

Use this skill after creating an epic (use `github-epic` skill first) when you need to:
- Break down the epic into specific tasks
- Create actionable issues that move toward the epic goal
- Link tasks to their parent epic via GitHub metadata

---

## Child Issues (Task Level)

Child issues define **what needs to be done** and **why it matters** to achieving the epic's goal.

### Include:

- ✅ Clear goal statement (what this accomplishes)
- ✅ Context explaining how this moves toward the epic
- ✅ What this enables or unblocks
- ✅ Concrete acceptance criteria

### Exclude:

- ❌ Step-by-step instructions ("do X, then Y, then Z")
- ❌ Explicit implementation details (unless critical to scope)
- ❌ Prescriptive "how to code this" directions

### Why This Approach:

- **Clarity**: Focus on outcomes, not prescriptive steps
- **Flexibility**: Developers can choose implementation approach
- **Context**: Clear connection between tasks and epic goals
- **Trust**: Respects developer expertise to determine "how"

---

## Task Template

```markdown
# Add network configuration data model

## Goal

Create the foundational data structures for storing network-specific rules, unblocking the validation logic and UI work.

## What This Enables

- Validation logic can check rules per network
- Settings UI can display/edit network configurations
- Posts can be validated before submission

## Acceptance Criteria

- [ ] NetworkConfig interface defined with network ID and rule properties
- [ ] Type exports available to other packages
- [ ] Documentation includes example usage
```

---

## Create and Link Child Issue

**CRITICAL**: Use GitHub's sub-issue metadata via GraphQL API. DO NOT put relationships in issue body text.

### Step 1: Create the child issue

```bash
CHILD_NUM=$(gh issue create --title "Task name" --body "..." --json number -q .number)
```

### Step 2: Get issue IDs for parent and child

```bash
# Get parent issue ID
PARENT_ID=$(gh api graphql -f query='{ 
  repository(owner: "OWNER", name: "REPO") { 
    issue(number: PARENT_NUM) { id } 
  } 
}' -q .data.repository.issue.id)

# Get child issue ID
CHILD_ID=$(gh api graphql -f query='{ 
  repository(owner: "OWNER", name: "REPO") { 
    issue(number: '$CHILD_NUM') { id } 
  } 
}' -q .data.repository.issue.id)
```

### Step 3: Link child to parent using GraphQL mutation

```bash
gh api graphql -f query='
mutation {
  addSubIssue(input: {
    issueId: "'$PARENT_ID'"
    subIssueId: "'$CHILD_ID'"
  }) {
    subIssue { id number title }
  }
}'
```

---

## Limits and Best Practices

**GitHub Limits:**
- One parent per issue
- Up to 100 sub-issues per parent
- 8 levels deep max

**Best Practices:**
1. **Link via Metadata**: Always use GraphQL API to create parent/child relationships
2. **Keep Issues Focused**: One clear task per child issue
3. **Include Epic Reference**: Mention parent issue in task body for human readability (e.g., "Part of #122")
