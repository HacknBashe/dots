# Global OpenCode Agent Rules

This file contains global rules and instructions that apply to all OpenCode sessions.

---

## GitHub Issue Management

### Detecting Repository from Context

**IMPORTANT**: You should detect the repository from the working directory path WITHOUT running commands.

**Path structure:**

- OpenCode is always run at the root of a repo (worktree or plain repo)
- Directories one level below `src/` are projects/repos
- Directories inside than that are branches

**Extract issue number from branch name:**

- Branch names follow pattern: `username-1234-description` (e.g., `nh-3609-complete-postform-...`)
- Extract the issue number (e.g., `3609`) and look it up directly

**DO NOT** run `gh repo view` or `git branch --show-current` unnecessarily.

---

## Project Tracking with GitHub Issues

### Issue Hierarchy Structure

**Use GitHub issues to track project work using a parent/child hierarchy.**

#### Parent Issues (Epic Level)

Parent issues define the **problem** and **desired outcome**, not the implementation path.

**Include:**

- ✅ Clear problem statement or user/developer need
- ✅ Why this matters (impact, pain points)
- ✅ Solution approach (high-level strategy)
- ✅ Success criteria (how we measure completion)

**Exclude:**

- ❌ List of child issues or tasks
- ❌ Implementation steps or instructions
- ❌ Specific file paths or technical details
- ❌ Anything that belongs in task-level issues

**Example:**

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

#### Child Issues (Task Level)

Child issues define **what needs to be done** and **why it matters** to achieving the epic's goal.

**Include:**

- ✅ Clear goal statement (what this accomplishes)
- ✅ Context explaining how this moves toward the epic
- ✅ What this enables or unblocks
- ✅ Concrete acceptance criteria

**Exclude:**

- ❌ Step-by-step instructions ("do X, then Y, then Z")
- ❌ Explicit implementation details (unless critical to scope)
- ❌ Prescriptive "how to code this" directions

**Example:**

```markdown
# Add network configuration data model

Part of #122 - [EPIC] Enable per-network post configuration

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

**Why This Approach:**

- **Clarity**: Focus on outcomes, not prescriptive steps
- **Flexibility**: Developers can choose implementation approach
- **Context**: Clear connection between tasks and epic goals
- **Trust**: Respects developer expertise to determine "how"

### Linking Parent and Child Issues

**CRITICAL**: Use GitHub's sub-issue metadata via GraphQL API. DO NOT put relationships in issue body text.

```bash
# Link child issue to parent using addSubIssue mutation
gh api graphql -f query='
mutation {
  addSubIssue(input: {
    issueId: "PARENT_ISSUE_ID"
    subIssueId: "CHILD_ISSUE_ID"
  }) {
    subIssue { id number title }
  }
}'
```

**To get issue IDs:**

```bash
gh api graphql -f query='
{
  repository(owner: "OWNER", name: "REPO") {
    issue(number: ISSUE_NUMBER) { id }
  }
}'
```

**Limits:** One parent per issue, up to 100 sub-issues, 8 levels deep.

### When to Create Issues

**Always create issues when:**

1. Starting a new feature or significant change
2. Planning work that spans multiple sessions
3. Work involves multiple related tasks
4. Need to track progress over time
5. Collaborating with others on the project

**Create Parent Issue First:**

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

**Then Create and Link Child Issues:**

```bash
# 1. Create child issue
CHILD_NUM=$(gh issue create --title "Task name" --body "..." --json number -q .number)

# 2. Get issue IDs and link them
PARENT_ID=$(gh api graphql -f query='{ repository(owner: "OWNER", name: "REPO") { issue(number: PARENT_NUM) { id } } }' -q .data.repository.issue.id)
CHILD_ID=$(gh api graphql -f query='{ repository(owner: "OWNER", name: "REPO") { issue(number: '$CHILD_NUM') { id } } }' -q .data.repository.issue.id)

gh api graphql -f query='mutation { addSubIssue(input: { issueId: "'$PARENT_ID'" subIssueId: "'$CHILD_ID'" }) { subIssue { number } } }'
```

### Issue Management Best Practices

1. **Link via Metadata**: Use GraphQL API to create parent/child relationships
2. **Keep Issues Focused**: One clear task per child issue
