#!/bin/bash

# Extract comprehensive branch information including git context, existing PRs, and related issues
# Usage: extract-branch-info.sh

set -e

PROJECT_ID="1532"

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo '{"error": "Not in a git repository"}' >&2
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# Get remote repository information
GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
OWNER=""
REPO=""
if [[ $GIT_REMOTE =~ git\.hubteam\.com[:/]([^/]+)/([^/]+)\.git ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
fi

# Get default branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Get commits on current branch (simplified)
COMMITS_JSON="[]"
if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
    # Get commits that are on current branch but not on default branch
    COMMITS=$(git log --oneline --no-merges origin/$DEFAULT_BRANCH..$CURRENT_BRANCH 2>/dev/null || echo "")
    if [ -n "$COMMITS" ]; then
        # Convert to simple JSON array
        COMMITS_JSON=$(echo "$COMMITS" | jq -R -s 'split("\n") | map(select(length > 0)) | map(split(" ")) | map({hash: .[0], message: (.[1:] | join(" "))})')
    fi
fi

# Get git status information
DIRTY_FILES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ -z "$DIRTY_FILES" ] || [ "$DIRTY_FILES" = "" ]; then
    DIRTY_FILES=0
fi

STAGED_CHANGES=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
if [ -z "$STAGED_CHANGES" ] || [ "$STAGED_CHANGES" = "" ]; then
    STAGED_CHANGES=0
fi

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

# Check for existing PR (simplified)
EXISTING_PR_JSON='null'
if [ -n "$OWNER" ] && [ -n "$REPO" ] && [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
    if gh pr list --repo "$OWNER/$REPO" --head "$CURRENT_BRANCH" --json number --limit 1 2>/dev/null | jq -e '.[0]' >/dev/null 2>&1; then
        EXISTING_PR_JSON=$(gh pr list --repo "$OWNER/$REPO" --head "$CURRENT_BRANCH" --json number,title,url,state --limit 1 2>/dev/null | jq '.[0]')
    fi
fi

# Extract issue information from branch name (simplified)
ISSUE_JSON='null'
if [[ $CURRENT_BRANCH =~ ([a-zA-Z0-9_-]+)-([0-9]{4})-(.+) ]] && [ -n "$OWNER" ] && [ -n "$REPO" ]; then
    ISSUE_NUMBER="${BASH_REMATCH[2]}"
    if ISSUE_INFO=$(gh issue view "$ISSUE_NUMBER" --repo "$OWNER/$REPO" --json title,body,state,url 2>/dev/null); then
        ISSUE_JSON=$(jq -n --argjson issue "$ISSUE_INFO" --arg number "$ISSUE_NUMBER" --arg owner "$OWNER" --arg repo "$REPO" '{
            issue: $issue,
            issueNumber: $number,
            owner: $owner,
            repo: $repo,
            epic: {},
            projectId: "'$PROJECT_ID'"
        }')
    fi
fi

# Try to find PR template in common locations
PR_TEMPLATE=""
TEMPLATE_LOCATIONS=(
    ".github/pull_request_template.md"
    ".github/PULL_REQUEST_TEMPLATE.md"
    "docs/pull_request_template.md"
    "docs/PULL_REQUEST_TEMPLATE.md"
    "PULL_REQUEST_TEMPLATE.md"
    "pull_request_template.md"
)

for template_path in "${TEMPLATE_LOCATIONS[@]}"; do
    if [ -f "$template_path" ]; then
        PR_TEMPLATE=$(cat "$template_path" 2>/dev/null || echo "")
        break
    fi
done

# If no local template found, try to get from GitHub API
if [ -z "$PR_TEMPLATE" ] && [ -n "$OWNER" ] && [ -n "$REPO" ]; then
    for template_path in "${TEMPLATE_LOCATIONS[@]}"; do
        TEMPLATE_CONTENT=$(gh api repos/$OWNER/$REPO/contents/$template_path --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
        if [ -n "$TEMPLATE_CONTENT" ]; then
            PR_TEMPLATE="$TEMPLATE_CONTENT"
            break
        fi
    done
fi

# Output combined JSON
jq -n --arg branch "$CURRENT_BRANCH" \
      --arg owner "$OWNER" \
      --arg repo "$REPO" \
      --arg remote "$GIT_REMOTE" \
      --arg defaultBranch "$DEFAULT_BRANCH" \
      --argjson commits "$COMMITS_JSON" \
      --argjson dirtyFiles "$DIRTY_FILES" \
      --argjson stagedChanges "$STAGED_CHANGES" \
      --arg repoRoot "$REPO_ROOT" \
      --argjson existingPr "$EXISTING_PR_JSON" \
      --argjson issue "$ISSUE_JSON" \
      --arg template "$PR_TEMPLATE" '{
    git: {
        branch: $branch,
        owner: $owner,
        repo: $repo,
        remote: $remote,
        defaultBranch: $defaultBranch,
        commits: $commits,
        dirtyFiles: $dirtyFiles,
        stagedChanges: $stagedChanges,
        repoRoot: $repoRoot
    },
    existingPr: $existingPr,
    issue: $issue,
    template: $template
}'