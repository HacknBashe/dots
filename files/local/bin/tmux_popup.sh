#!/bin/bash

# Check if we're already in a popup or in the popups session
if [ "$(tmux display-message -p '#{session_name}')" = "popups" ]; then
  # We're in the popups session, so just close the popup
  tmux detach-client
  exit 0
fi

# Get identifiers for the current tmux context
CURRENT_SESSION=$(tmux display-message -p "#{session_name}")
CURRENT_WINDOW=$(tmux display-message -p "#{window_id}")
CURRENT_PATH=$(tmux display-message -p "#{pane_current_path}")
POPUP_SESSION="popups"
WINDOW_NAME="${CURRENT_SESSION}_${CURRENT_WINDOW}"

# Create the popups session if it doesn't exist
if ! tmux has-session -t "$POPUP_SESSION" 2>/dev/null; then
  # Create session with the first window already having the correct name
  tmux new-session -d -s "$POPUP_SESSION" -n "$WINDOW_NAME" -c "$CURRENT_PATH"
  # Launch popup immediately
  tmux popup -E -w 90% -h 90% -x C -y C "tmux attach-session -t $POPUP_SESSION"
  exit 0
fi

# Check if the window for this session+window already exists in popups session
if tmux list-windows -t "$POPUP_SESSION" -F "#{window_name}" | grep -q "^$WINDOW_NAME$"; then
  # Window exists, select it
  tmux select-window -t "$POPUP_SESSION:$WINDOW_NAME"
else
  # Create a new window for this session+window
  tmux new-window -t "$POPUP_SESSION" -n "$WINDOW_NAME" -c "$CURRENT_PATH"
fi

# Launch popup attached to the popups session
tmux popup -E -w 90% -h 90% -x C -y C "tmux attach-session -t $POPUP_SESSION"
