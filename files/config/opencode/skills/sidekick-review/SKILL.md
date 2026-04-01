---
name: sidekick-review
description: Request and manage AI code reviews from HubSpot's Sidekick AI reviewer on GitHub PRs. Use when the user wants to request a sidekick review, check sidekick review status, or re-request a sidekick review after pushing changes.
license: MIT
compatibility: opencode
---

## What I do

Request, monitor, and respond to AI code reviews from HubSpot's Sidekick AI reviewer on GitHub pull requests.

## When to use me

Use this skill when:
- Creating or updating a pull request that needs an AI review
- The user asks to "request a sidekick review" or "get sidekick to review"
- Re-requesting a review after force-pushing or addressing feedback
- Checking whether sidekick has reviewed a PR yet

---

## Sidekick AI Reviewer Accounts

Sidekick reviews come from a pool of bot accounts. The primary account to request is:

- `sidekickai1_hubspot`

Reviews may come from any of these accounts:
- `sidekickai1_hubspot`
- `sidekickai2_hubspot`
- `sidekickai3_hubspot`

**IMPORTANT**: Do NOT request reviews from `sidekick-cr[bot]` — that is NOT the correct account.

---

## Requesting a Review

Use the GitHub API to request a review. The `gh pr edit --add-reviewer` command does not work for these accounts due to shell escaping issues with brackets, so always use the API:

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers \
  --method POST \
  -f 'reviewers[]=sidekickai1_hubspot'
```

Verify the request was accepted by checking the response:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers \
  --method POST \
  -f 'reviewers[]=sidekickai1_hubspot' \
  --jq '{requested_reviewers: [.requested_reviewers[].login]}'
```

The response should include `sidekickai1_hubspot` in the `requested_reviewers` array.

---

## Checking Review Status

Poll for reviews and filter for sidekick accounts:

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --jq '.[] | select(.user.login | startswith("sidekickai")) | {user: .user.login, state: .state, body: .body[0:500]}'
```

### Review States

- **COMMENTED** with "Review complete. No comments" — Clean review, no issues found
- **COMMENTED** with inline comments — Sidekick found issues; check PR comments for details
- **CHANGES_REQUESTED** — Sidekick found blocking issues
- **APPROVED** — Sidekick approved the PR

### Checking Inline Comments

If sidekick left comments, read them:

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '.[] | select(.user.login | startswith("sidekickai")) | {user: .user.login, body: .body, path: .path, line: .line}'
```

---

## Re-requesting After Changes

After pushing new commits or force-pushing, you must re-request the review:

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers \
  --method POST \
  -f 'reviewers[]=sidekickai1_hubspot'
```

---

## Timing

- Sidekick typically responds within 1-3 minutes after being requested
- Wait at least 2 minutes before checking for a review
- If no review appears after 5 minutes, try re-requesting

---

## Typical Workflow

1. Create/update PR and push changes
2. Request sidekick review: `gh api repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers --method POST -f 'reviewers[]=sidekickai1_hubspot'`
3. Wait ~2 minutes
4. Check for review: `gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --jq '.[] | select(.user.login | startswith("sidekickai"))'`
5. If comments were left, read and address them
6. If changes were made, push and re-request (go to step 2)
7. Done when sidekick says "Review complete. No comments" or leaves no blocking feedback

---

## Sidekick Review Comment Format

Sidekick reviews include HTML comments for metadata:
```
<!-- sidekick-agent:REVIEW,REVIEW_RELIABILITY -->
```

Review bodies may include:
- BRAVE risk assessment (rollout plan, automated testing, verification plan)
- Inline code comments on specific files/lines
- A feedback prompt: "Feedback? React with :+1:/:-1:, or reply in a thread."
