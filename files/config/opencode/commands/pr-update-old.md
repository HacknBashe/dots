# PR Update Command

Update the pr for this branch based on the following instructions

## Steps:

1. **Check current PR content**:

   ```bash
   gh pr view --json title,body
   ```

2. **Extract issue number from branch name** (format: name-####-description):

   - Look at current branch name
   - Extract the issue number (4 digits)
   - If there's no issue, just remove the related links section from the ticket

3. **Review current commits and changes**:

   - Check git log to see what commits are actually on the branch
   - Compare existing PR body details with current commits
   - Identify any outdated information that references removed commits or changes
   - Note any new commits that aren't reflected in the current PR description

4. **Update PR body** keeping existing structure but filling in:

   - **IMPORTANT**: The PR must start with "# Changes" - nothing should come before it
   - If there's any auto-generated content (like "Created by Claude" comments or commit info) above the Changes section, move relevant details to the Changes section and delete everything above "# Changes"
   - **Changes section**: 
     - Add bullet points describing what was modified based on current commits
     - Remove any outdated details that reference commits or changes no longer on the branch
     - Ensure all listed changes accurately reflect the current state of the branch
     - Include any relevant commit details that were moved from above
   - **Related links**: Update "Closes" link with correct repo and issue number
   - Keep existing Screenshots and Pre-Merge Checklist sections unchanged
   - **Special instructions**: Parse any additional instructions included with the command (e.g., "no screens" to remove Screenshots section, or other specific modifications to the PR template)

5. **Use gh pr edit command**:

   **CRITICAL WARNINGS:**

   - **DO NOT use heredoc (cat <<'EOF') when updating existing PRs** - it breaks existing image links and content
   - **NEVER add escape characters (backslashes)** around ANY content - values, props, image URLs, or quoted text
   - **PRESERVE existing image links EXACTLY** - do not modify URLs, markdown syntax, or any formatting
   - When updating PRs with existing content, read the current body first and preserve all formatting

   For new PRs without existing screenshots:

   ```bash
   gh pr edit --body "$(cat <<'EOF'
   # Changes

   - [Describe specific changes made]
   - [Additional changes if any]

   ## Related links

   Closes https://github.com/HubSpotEngineering/[CORRECT_REPO]/issues/[ISSUE_NUMBER]

   ## Screenshots

   | Before     | After      |
   | ---------- | ---------- |
   | PASTE_HERE | PASTE_HERE |

   ## Pre-Merge Checklist

   - [ ] I ran AT tests against this branch
   EOF
   )"
   ```

   **For PRs with existing content (especially images):**

   - Read current PR body with `gh pr view --json body`
   - Preserve ALL existing content exactly as-is
   - Only update the Changes section and Related links
   - Use direct string construction, never heredoc
   - Test that image links still work after update

## Notes:

- For Social team: Issues are typically in ProductSupport repo for external tickets or SocialCoreTeam for internal
- Keep the same PR title unless specifically asked to change it
- Only update the content, preserve the existing template structure
- **NEVER add escape characters**: Write `type=info` not `type=\info\`, write `marginBlockEnd=400` not `marginBlockEnd=\400\`
- **PR must start with "# Changes"**: Remove any auto-generated content, comments, or commit info that appears before the Changes section
