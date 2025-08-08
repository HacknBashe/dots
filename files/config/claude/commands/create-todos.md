# Create Todos from GitHub Issue Command

This command creates a todo list based on the current branch's GitHub issue. It extracts detailed tasks from the issue while preserving important details like line numbers and specific requirements.

## Steps:

1. **Get current branch name**:

   ```bash
   git branch --show-current
   ```

2. **Extract issue number from branch name** (format: name-####-description):

   - Look at current branch name
   - Extract the issue number (4 digits)

3. **Fetch the GitHub issue details**:

   ```bash
   ghe issue view --repo HubSpot/SocialCoreTeam ####
   ```

   Note: For Social team, issues are in SocialCoreTeam repo by default. If the issue is not found there, try ProductSupport repo for external tickets.

4. **Create todo list from issue content**:

   - Read through the issue description, acceptance criteria, and any task lists
   - Match the specificity level of the original ticket:
     - If ticket is specific (e.g., "1 usage at line 22 needs manual migration"), create 1 specific todo
     - If ticket is broad (e.g., "Implement user authentication"), break down into logical steps
   - Preserve specific details like:
     - File paths and line numbers
     - Exact error messages or symptoms
     - Specific test cases or scenarios
     - Browser/environment requirements
     - Code snippets or implementation details
   - Retain priority information if specified in the issue

5. **Use TodoWrite tool to create the todo list**:
   - Set appropriate priority levels (high/medium/low) based on issue urgency
   - All todos should start with status "pending"
   - Do NOT start working on any tasks - only create the todo list
   - Include enough detail in each todo that work can begin without re-reading the issue

## Example Todo Creation:

**Specific ticket** - "1 usage: Usage of a UIComponent outside of a JSX element requires manual migration. #L22":
- "Migrate UIComponent usage at line 22 in SocialUI/components/tour/TourStep.tsx"

**Broad ticket** - "Implement user authentication system":
- "Create user registration API endpoint"
- "Add login/logout functionality"
- "Implement JWT token management"
- "Add password reset flow"
- "Create user session management"

Match the granularity of the original ticket - don't add steps to specific tickets, but do break down vague ones.

## Notes:

- DO NOT start working on todo list tasks until the user approves the todo list and says to begin
- Once given permission to start working, return to normal behavior for all future commands - no additional permission needed
- Preserve as much detail from the original issue as possible
- Break down complex tasks into smaller, actionable items
- Use appropriate priority levels based on issue severity/urgency
- If the issue contains sub-tasks or checkboxes, convert each into a separate todo
