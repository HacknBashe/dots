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

# Commit any local changes first (before pulling)
git add .
if ! git diff --cached --quiet; then
	TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
	git commit -m "Auto-commit: $TIMESTAMP"
	echo "Committed local changes"
fi

# Pull with rebase to replay remote changes under our commit
echo "Pulling latest changes..."
if ! git pull --rebase; then
	echo "Error: Rebase conflict — aborting rebase"
	git rebase --abort
	exit 1
fi

# Push changes to remote repository
echo "Pushing changes to remote repository..."
git push || {
	echo "Error: Failed to push changes"
	exit 1
}

echo "Sync complete"
