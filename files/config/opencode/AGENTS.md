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

## Git Workflows

For git-related operations:
- Use the `git-commit` skill for commit message guidelines
- Use the `pr-create` skill for creating/updating pull requests
