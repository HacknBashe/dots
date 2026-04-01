---
name: github-issue-search
description: MUST USE before any GitHub issue operation -- searching, creating, filing sub-issues, or linking to epics/sprints. Contains the repo search order (SocialCoreTeam vs Social) without which you WILL look in the wrong repo. Use whenever the user mentions epics, sprints, KTLO, filing issues, or creating sub-issues.
license: MIT
compatibility: opencode
---

## What I do

Find and resolve GitHub issues across HubSpot Social repositories, including epics, sprint trackers, KTLO issues, and branch-linked issues.

## When to use me

Use this skill when:
- Searching for any GitHub issue, epic, or sprint tracker
- Looking up the issue for the current branch
- Filing a new issue and need to know which repo to create it in
- Linking issues to epics or sprint trackers
- Reading or fetching issue details related to ongoing work
- Needing issue context before creating a PR or planning work

---

## Detecting Repository from Context

**IMPORTANT**: Detect the repository from the working directory path WITHOUT running commands.

- OpenCode is always run at the root of a repo (worktree or plain repo)
- Directories one level below `src/` are projects/repos
- Directories inside that are branches

**DO NOT** run `gh repo view` or `git branch --show-current` unnecessarily.

---

## Branch Name Pattern

Branch names follow the pattern: `username-1234-description`

Extract the **number** as the issue number. Examples:
- `nh-3609-complete-postform-migration` -> issue `3609`
- `nhackford-142-fix-tooltip` -> issue `142`

---

## Repository Search Order (HubSpot Social)

For HubSpot Social team repositories, issues may live in multiple repos. Search in this order:

1. `HubSpotEngineering/SocialCoreTeam` (planning/tracking repo)
2. The current code repository
3. `HubSpotProductSupport/ProductSupport`

Stop at the first repo that returns a result.

### Issue tracking repo vs code repo

- Sprint planning, KTLO, and epic issues live in **`HubSpotEngineering/SocialCoreTeam`**, NOT in the code repo (`HubSpotEngineering/Social`).
- When creating task issues that track work (e.g., KTLO tasks, sprint tasks), create them in `HubSpotEngineering/SocialCoreTeam` and link as sub-issues to the relevant sprint/epic.
- Branch issue numbers (from `username-1234-description`) also refer to `SocialCoreTeam` issues.

---

## How to fetch

```bash
gh issue view <number> --repo <owner>/<repo>
```

Try each repo in order until one succeeds.

---

## Auto-assign

If the issue number was extracted from the **current branch name** (i.e., you are actively working on this issue, not just referencing it), ensure it is assigned to `nhackford_hubspot`:

```bash
gh issue edit <number> --repo <owner>/<repo> --add-assignee nhackford_hubspot
```

Do this silently after fetching the issue — do not ask for confirmation.
