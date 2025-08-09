#!/bin/bash

# Smart PR Creation Script
# Gathers context and uses AI to create intelligent pull requests
# Usage: smart-pr-create.sh

set -e

echo "🔍 Gathering repository context..."

# Extract all branch information (git + existing PR + issue info)
CONTEXT_DATA=$(extract-branch-info.sh)

# Find pr-create.md command file in common locations
PR_COMMAND_FILE=""
for location in \
    "$HOME/.config/dots/files/config/claude/commands/pr-create.md" \
    "$(dirname "$0")/pr-create.md" \
    "./pr-create.md"; do
    if [[ -f "$location" ]]; then
        PR_COMMAND_FILE="$location"
        break
    fi
done

if [[ -z "$PR_COMMAND_FILE" ]]; then
    echo "❌ Error: Could not find pr-create.md command file"
    echo "   Looked in:"
    echo "   - $HOME/.claude/commands/pr-create.md"
    echo "   - $(dirname "$0")/pr-create.md"
    echo "   - ./pr-create.md"
    exit 1
fi

# Call Claude CLI with command file and context data
echo "🧠 Using AI to generate PR command..."
PR_COMMAND=$(echo -e "$(cat "$PR_COMMAND_FILE")\n\n## Context Data\n\nThe following JSON data contains all relevant information extracted from the current repository state:\n\n\`\`\`json\n$CONTEXT_DATA\n\`\`\`" | claude --print)

# Extract and run command from code block
# Save the command block to a temp file to preserve formatting
TEMP_CMD=$(mktemp)
echo "$PR_COMMAND" | sed -n '/```/,/```/p' | sed '1d;$d' > "$TEMP_CMD"

if [[ -s "$TEMP_CMD" ]]; then
    echo "🚀 Executing command..."
    bash "$TEMP_CMD"
    rm "$TEMP_CMD"
else
    echo "ℹ️  $PR_COMMAND"
    rm "$TEMP_CMD"
fi

echo "✅ PR creation process completed!"
