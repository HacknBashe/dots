---
name: git-commit
description: Guidelines for writing consistent conventional commit messages
license: MIT
compatibility: opencode
---

## What I do

- Guide you on writing consistent, conventional commit messages
- Help you choose the right commit type prefix
- Ensure commits follow the project's format conventions

## When to use me

Use this skill when:

- Creating git commits
- Reviewing commit messages before pushing
- Need guidance on what type of commit to use

---

## Commit Message Format

All commit messages must follow this structure:

<type>(<scope>): <subject>

[optional body]

[optional footer]

Type and scope are always required. The actual commit message is plain text - do NOT include markdown formatting like backticks

### Type (Required)

The type must be one of the following:

- **feat**: Adding or removing a feature
  - Example: `feat(auth): add OAuth login support`
  - Example: `feat(api): remove deprecated v1 endpoints`

- **fix**: Bug fixes
  - Example: `fix(parser): handle null values in JSON response`
  - Example: `fix(ui): prevent crash when user profile is empty`

- **tweak**: Configuration changes, small adjustments, rule changes for ais
  - Example: `tweak(eslint): enable no-unused-vars rule`
  - Example: `tweak(nginx): increase timeout to 30s`
  - Example: `tweak(theme): adjust button padding`
  - Example: `tweak(opencode): adjust git-commit skil`

- **chore**: Maintenance, cleanup, version bumps, dependency updates
  - Example: `chore(deps): update Node to 20.11`
  - Example: `chore(build): remove unused webpack config`
  - Example: `chore(flake): bump flake inputs`
  - Example: `chore: bump version to 2.1.0`

- **refactor**: Code restructuring without changing behavior
  - Example: `refactor(auth): extract validation logic to separate module`
  - Example: `refactor(api): simplify error handling`

- **docs**: Documentation changes for humans. Changes to AI markdown rules/skills/commands are tweaks, not docs
  - Example: `docs(readme): add installation instructions`
  - Example: `docs(api): update endpoint examples`

- **test**: Adding or updating tests
  - Example: `test(auth): add integration tests for login flow`
  - Example: `test(parser): cover edge cases`

- **perf**: Performance improvements
  - Example: `perf(db): add index on user_id column`
  - Example: `perf(render): memoize expensive calculations`

- **style**: Formatting, whitespace, code style (no logic change)
  - Example: `style(components): format with prettier`
  - Example: `style(css): organize imports alphabetically`

- **ci**: CI/CD configuration changes
  - Example: `ci(github): add test workflow`
  - Example: `ci(docker): optimize build cache`

- **build**: Build system or tooling changes
  - Example: `build(webpack): add source maps for dev mode`
  - Example: `build(vite): enable CSS code splitting`

### Scope (Required)

The scope should be the **name of the component/package/module** being modified:

- Use lowercase
- Be specific: `auth`, `api`, `ui`, `parser`, `quickshell`, `hyprland`, etc.
- For multiple scopes, pick the primary one or use a parent scope

### Subject (Required)

- Use imperative mood: "add" not "added" or "adds"
- Don't capitalize first letter
- No period at the end
- Keep it concise (50 chars or less ideally)

### Body (Optional)

- Use when the commit needs more explanation
- Explain **why**, not what (the diff shows what)
- Wrap at 72 characters

### Footer (Optional)

- Reference issues: `Closes #123`
- Breaking changes: `BREAKING CHANGE: description`

---

## Examples

### Good Commits

- feat(auth): add password reset flow
- fix(parser): handle malformed JSON without crashing
- tweak(eslint): disable no-console for dev environment
- chore(deps): update all npm packages to latest
- refactor(api): extract database queries to repository layer
- docs(readme): add troubleshooting section
- test(auth): add unit tests for token validation
- perf(render): lazy load images below fold
- style(components): run prettier on all files
- ci(github): cache npm dependencies in workflow
- build(vite): enable gzip compression for production

### Bad Commits (Don't do this)

- Fixed stuff — too vague, no type/scope
- feat: Added new feature. — capitalized, has period, no scope
- update config — no type, not imperative
- WIP — not descriptive
- bug(auth): Fixes the login bug — use 'fix' not 'bug', capitalized
- feat(everything): made changes — scope too broad, vague

---

## Quick Decision Guide

**Adding/removing functionality?** → `feat`
**Fixing a bug?** → `fix`
**Adjusting config/settings/AI instructions/commands/skills?** → `tweak`
**Updating dependencies or cleaning up?** → `chore`
**Restructuring code?** → `refactor`
**Writing documentation for humans?** → `docs`
**Adding/updating tests?** → `test`
**Improving performance?** → `perf`
**Just formatting?** → `style`
**CI/CD changes?** → `ci`
**Build tooling changes?** → `build`

---

## Best Practices

1. **Commit often**: Small, focused commits are better than large ones
2. **One logical change per commit**: Don't mix refactoring with features
3. **Test before committing**: Ensure code works
4. **Review your diff**: Use `git diff --cached` before committing
5. **Write for others**: Someone should understand your commit in 6 months
