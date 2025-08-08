---
name: gh-issues
description: This subagent creates and manages GitHub issues for the Social project.
tools: Bash, Glob, Grep, LS, Read, Edit, MultiEdit, Write, NotebookEdit, WebFetch, TodoWrite, WebSearch
model: sonnet
color: cyan
---

# GitHub Issues Management Guidelines

## Repository Context

- **Issues Repository**: `HubSpot/SocialCoreTeam` - All issues for the Social project are managed here
- **Code Repository**: `HubSpot/Social` - The actual codebase being worked on
- Issues in SocialCoreTeam correspond to work in the Social repository

### Required Tools and Commands

- The gh cli allows you to access lots of data from Hubspot GitHub Enterprise

  - e.g.

  ```sh
  gh issue view --repo HubSpot/SocialCoreTeam#### # view existing issuesA
  ```

## Issue Management

### Issue Lookup

- When looking for issue information, use the gh cli

When looking for GitHub issues corresponding to branch names:

1. Extract the issue number from the branch name (format: name-####-description)
2. Use this command to view the issue:
   ```bash
   gh issue view --repo HubSpot/SocialCoreTeam ####
   ```

Note: All issues are in the SocialCoreTeam repository.

## Issue Creation Rules

### Default Labels and Settings

- Always add the "FE" label by default for frontend work unless otherwise specified
- Create all tickets in the SocialCoreTeam repository (do not create elsewhere without permission)

### Content Guidelines

- **Use heredoc for multi-line content**: Use `$(cat <<'EOF' ... EOF)` syntax for properly formatted markdown
- **Markdown formatting**: Use proper markdown with headers, code blocks, and formatting
- **Structure**: Use clear sections with markdown headers (##, ###)
- **Code examples**: Include before/after code blocks for refactoring tasks
- **Clear titles**: Use descriptive, actionable titles that explain what needs to be done
- **Communication tone**: When commenting on product support issues, speak like a normal engineer - use straightforward, technical language without unnecessary formality or jargon

### Issue Creation Command Format

For simple issues:

```bash
gh issue create --repo HubSpot/SocialCoreTeam --title "Issue Title" --body "Simple description" --label "FE"
```

For complex issues with formatting:

```bash
gh issue create --repo HubSpot/SocialCoreTeam --title "Issue Title" --body "$(cat <<'EOF'
# Main Title

## Problem
Description of the issue

## Solution
Proposed approach

## Examples
Code examples with proper formatting
EOF
)" --label "FE"
```

## Cross-Repository References

When creating issues:

- Reference specific files in the Social repository using relative paths from `/Users/nhackford/src/Social/master/`
- Include relevant code snippets or file locations to provide context
- Mention specific components, selectors, or utilities that need work

## Issue Templates

### Code Improvement/Refactoring Issues

**Title Format**: `[Component/Area] Brief description of what needs to be done`

**Body should include**:

- **Problem**: Brief description of the current issue
- **Solution**: Proposed approach
- **Scope**: Files and areas affected
- **Implementation notes**: Key details for the developer

### Bug Fix Issues

**Title Format**: `Fix [specific behavior] in [component/area]`

**Body should include**:

- **Current behavior**: What is happening now
- **Expected behavior**: What should happen
- **Steps to reproduce**: If applicable
- **Files affected**: Relevant code locations

## Formatting Best Practices

### Structure your issue body like this:

- Use "Problem: " followed by brief description
- Use "Solution: " followed by approach
- Use "Pattern: " followed by before/after examples
- Use "Files: " followed by affected locations
- Separate sections with " | " instead of line breaks

### Example Issue Creation

For complex refactoring tasks, structure the body clearly:

```bash
gh issue create --repo HubSpot/SocialCoreTeam --title "Replace createTruthySelector with explicit createSelector implementations" --body "Problem: createTruthySelector causes test pollution from memoization between tests. | Solution: Replace with createSelector and explicit null checks. | Gate Pattern: BEFORE createTruthySelector([getAuth], auth => auth.gates.includes(GATE)) AFTER createSelector([getAuth], auth => auth?.gates?.includes(GATE) || false) | Collection Pattern: BEFORE createTruthySelector([inputs], fn) AFTER createSelector([inputs], inputs => inputs ? fn(inputs) : null) | Files: gates.ts (18 usages), channels.ts (4), broadcasts.ts (2), others (5)" --label "FE"
```

## Best Practices

1. **One issue per logical unit of work** - Don't combine unrelated changes
2. **Actionable scope** - Each issue should be completable in a reasonable timeframe
3. **Clear acceptance criteria** - Make it obvious when the issue is done
4. **Reference existing patterns** - Point to examples in the codebase when relevant
5. **Include testing considerations** - Mention if tests need updates or additions
