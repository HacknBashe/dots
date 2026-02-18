# PR Create Command

Create or update a pull request for the current branch.

## Instructions

1. Load the `pr-create` skill and follow its instructions exactly for:
   - Gathering branch context via `extract-branch-info.sh`
   - PR title format and body structure
   - Content guidelines and special considerations

2. Since this is an interactive session (not a script), execute the commands directly:

   **For new PRs:**
   ```bash
   gh pr create --title "TITLE" --body "BODY" --assignee nhackford --web
   ```

   **For existing PRs:**
   ```bash
   gh pr edit --title "TITLE" --body "BODY"
   ```
