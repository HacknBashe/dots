#!/bin/bash

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

echo "Changes committed successfully"
