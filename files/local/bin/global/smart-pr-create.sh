#!/bin/bash

# Smart PR Creation Script
# Gathers context and uses AI to create intelligent pull requests
# Usage: smart-pr-create.sh

set -e

# Determine the correct opencode command (dvx wrapper for HubSpot auth or direct)
# Use Sonnet for speed/cost
if command -v dvx &>/dev/null; then
	OPENCODE_CMD="dvx opencode run -m anthropic/claude-sonnet-4-0"
else
	OPENCODE_CMD="opencode run -m anthropic/claude-sonnet-4-0"
fi

echo "🔍 Gathering repository context..."

# Extract all branch information (git + existing PR + issue info)
CONTEXT_DATA=$(extract-branch-info.sh)

# Call Claude CLI to generate PR command
echo "🧠 Using AI to generate PR command..."
PR_COMMAND=$(echo -e "Generate a GitHub CLI command for creating or updating a pull request based on the context below.\n\nIMPORTANT: You are being called from a script. Do NOT execute any commands. Do NOT use the bash tool. Return ONLY the gh command as text inside a single fenced code block. The calling script will handle execution. For new PRs, include the --web flag.\n\n## Context Data\n\nThe following JSON data contains all relevant information extracted from the current repository state:\n\n\`\`\`json\n$CONTEXT_DATA\n\`\`\`" | $OPENCODE_CMD)

# Extract and run ONLY the first code block from the response
# Using awk to stop after the first closing fence, preventing multiple commands from being executed
TEMP_CMD=$(mktemp)
echo "$PR_COMMAND" | awk '/^```/{if(n++) exit; next} n' >"$TEMP_CMD"

if [[ -s "$TEMP_CMD" ]]; then
	echo "🚀 Executing command..."
	bash "$TEMP_CMD"
	rm "$TEMP_CMD"
else
	echo "ℹ️  $PR_COMMAND"
	rm "$TEMP_CMD"
fi

echo "✅ PR creation process completed!"
