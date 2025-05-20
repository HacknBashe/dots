#!/bin/bash

# Create a new tmux tab for vi
tmux new-window -n "nvim"
tmux send-keys -t "nvim" "vi" C-m

# Create a second tmux tab for claude
tmux new-window -n "claude"
tmux send-keys -t "claude" "claude" C-m

# Create a third tmux tab for bend commands
tmux new-window -n "bend"
tmux send-keys -t "bend" "bend yarn" C-m
# Type the bend command but don't execute it
tmux send-keys -t "bend" "bend reactor serve SocialUI social-composer-lib --mode --update --enable-tools --ts-watch"

# Close the original window (use its index or name if known)
tmux kill-window -t 1
