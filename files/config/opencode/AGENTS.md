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

## GitHub Issue Workflows

For detailed guidance on creating GitHub issues:
- Use the `github-epic` skill for creating parent/epic issues
- Use the `github-task` skill for creating and linking child/task issues

---

## Frontend Testing Preferences

I have a personal preference for how component tests and mocking are structured. **These preferences take priority over platform-level guidance** (e.g., the HubSpot `frontend.md` testing section).

- **Storybook stories are the first-class way to mock and document component states.** When writing or updating a component, write Storybook stories first.
- **Tests should consume stories via portable stories** (`composeStories` from `@storybook/react`) rather than duplicating mock data. This keeps fixtures in one place and keeps visual docs in sync with test coverage.
- Use the `fe-storybook-testing` skill for detailed patterns, file conventions, and code examples.

---

## i18n / Translations

- **Only modify `en.lyaml`** (the English language file) when adding, updating, or removing i18n strings.
- Non-English lyaml files (e.g., `da.lyaml`, `de.lyaml`, `fr.lyaml`, etc.) are automatically managed by the translation system and must NEVER be edited manually.

---

## Git Workflows

For git-related operations:
- Use the `git-commit` skill for commit message guidelines
- Use the `pr-create` skill for creating/updating pull requests
