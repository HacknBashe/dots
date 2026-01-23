#!/usr/bin/env bash

NOTES_DIR="$HOME/notes"

# Check if notes directory exists
if [ ! -d "$NOTES_DIR" ]; then
  echo "Notes directory doesn't exist"
  exit 1
fi

# Check if it's a git repository
if [ ! -d "$NOTES_DIR/.git" ]; then
  echo "Not a git repository"
  exit 1
fi

# Navigate to the directory
cd "$NOTES_DIR" || exit 1

# Stash any uncommitted changes
git_status=$(git status --porcelain)
has_changes=false

if [ -n "$git_status" ]; then
  echo "Stashing uncommitted changes..."
  has_changes=true
  git stash push -m "Auto-stash before pull" || {
    echo "Error: Failed to stash changes"
    exit 1
  }
fi

# Pull latest changes
echo "Pulling latest changes..."
git pull --rebase || {
  echo "Error: Failed to pull changes"
  if [ "$has_changes" = true ]; then
    echo "Restoring stashed changes..."
    git stash pop
  fi
  exit 1
}

# Apply stashed changes if any were stashed
if [ "$has_changes" = true ]; then
  echo "Applying stashed changes..."
  git stash pop || {
    echo "Error: Failed to apply stashed changes"
    echo "Your changes are in the stash. Use 'git stash list' and 'git stash apply' to recover them."
    exit 1
  }
fi

# Add all changes
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
  echo "No changes to commit"
  exit 0
fi

# Commit changes with timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "Auto-commit: $TIMESTAMP"

# Push changes to remote repository
echo "Pushing changes to remote repository..."
git push || {
  echo "Error: Failed to push changes"
  exit 1
}

echo "Changes committed and pushed successfully"
