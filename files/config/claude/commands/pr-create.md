# PR Create Command

Create a pull request with an intelligent, contextually rich body based on git commits, related issues, and repository context.

## Instructions

1. **Gather branch context** (if not already provided):
   - If JSON context data is not supplied, run `/Users/nhackford/.config/dots/files/local/bin/extract-branch-info.sh` to gather branch information
   - This script will provide git commits, related issues, epic context, and repository details needed for PR creation

2. **Check for existing PR**:
   - If `existingPr` is not null in the context data, update the existing PR instead of creating a new one
   - Use `gh pr edit` to update the PR title and body with current information
   - Ensure the updated content reflects the current state of commits and removes any outdated information

3. **Analyze the provided context**:
   - Review git commits to understand what changes were made
   - Check if there's a related issue linked to this branch
   - Look at epic context if the issue is part of a larger initiative
   - Consider the repository's PR template if available

4. **Generate PR title**:
   - Create a concise, descriptive title based on the commits and/or related issue
   - Use format: `[Type]: Description` (e.g., "Fix: Handle edge case in user validation")
   - Common types: Fix, Feature, Update, Refactor, Docs, Test, etc.

5. **Create PR body** following this structure:

   **CRITICAL: The PR body MUST start with "# Changes" - nothing should come before it**

   ```markdown
   # Changes

   - [Describe specific changes based on commits]
   - [Additional changes if any]
   - [Include technical details that would help reviewers]

   ## Related links

   Closes https://git.hubteam.com/[OWNER]/[REPO]/issues/[ISSUE_NUMBER]

   [If part of an epic, add:]
   Part of epic: [Epic Title](https://git.hubteam.com/[OWNER]/[REPO]/issues/[EPIC_NUMBER])

   ## Screenshots

   | Before     | After      |
   | ---------- | ---------- |
   | PASTE_HERE | PASTE_HERE |

   ## Pre-Merge Checklist

   - [ ] I ran AT tests against this branch
   ```

6. **Content guidelines**:
   - **Changes section**: Analyze commits to create meaningful bullet points describing what was modified
   - **Related links**: Use the exact repository and issue number from the context
   - **Epic context**: If the related issue is part of an epic, mention it
   - **Be specific**: Include technical details that would help code reviewers
   - **Focus on "why"**: Explain the reasoning behind changes, not just what changed

7. **Special considerations**:
   - If no related issue: Remove the "Related links" section
   - If no commits (new branch): Focus on intended changes from branch name
   - If repository has a custom PR template: Adapt the structure accordingly
   - For HubSpot Social team: Issues may be in ProductSupport or SocialCoreTeam repos

## Output Requirements

Output ONLY the appropriate GitHub CLI command:

**For new PRs:**
```
gh pr create --title "TITLE_HERE" --body "BODY_HERE" --assignee nhackford --web
```

**For existing PRs:**
```
gh pr edit --title "TITLE_HERE" --body "BODY_HERE"
```

**CRITICAL Requirements**:
- Use proper shell escaping for the title and body
- The PR body MUST start with "# Changes" 
- Escape quotes and special characters properly for shell execution
- For existing PRs, generate a completely fresh body based on current commits (don't try to merge with existing content)
- Ensure updated PR content reflects current state and removes any outdated information
