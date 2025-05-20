#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
  selected=$1
else
  selected=$(find ~/ ~/src ~/.config -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
  exit 0
fi

# Check if the selected directory is a bare Git repository
work_dir=$selected
session_name=$(basename "$selected" | tr . _)

# First check if it's a git directory at all
if (cd "$selected" && git rev-parse --git-dir &>/dev/null); then
  # Use git's own command to check if it's a bare repo
  if (cd "$selected" && is_bare=$(git config --get --bool core.bare) && [ "$is_bare" = "true" ]); then
    # It's a bare repo, check if it has a master worktree
    if [ -d "$selected/master" ]; then
      work_dir="$selected/master"
      repo_name=$(basename "$selected")
      session_name="${repo_name}_master"
    fi
  fi
fi

tmux_running=$(pgrep tmux)

zoxide add "$selected"

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  tmux new-session -s "$session_name" -c "$work_dir"
  exit 0
fi

if ! tmux has-session -t="$session_name" 2>/dev/null; then
  tmux new-session -ds "$session_name" -c "$work_dir"
fi

if [[ -z $TMUX ]]; then
  tmux attach -t "$session_name"
else
  tmux switch-client -t "$session_name"
fi
