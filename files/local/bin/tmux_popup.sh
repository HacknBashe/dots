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

# Get optional command arguments
if [ $# -gt 0 ]; then
  POPUP_ID="$1"
  COMMAND="$1"
  if [ "$1" = "lazygit" ]; then
    COMMAND="${COMMAND} -ucf $HOME/.config/lazygit/popupconfig.yml,$HOME/.config/lazygit/config.yml"
  fi
else
  POPUP_ID="default"
  COMMAND=""
fi
WINDOW_NAME="${CURRENT_SESSION}_${CURRENT_WINDOW}_${POPUP_ID}"

# Set up a global hook for session destruction
tmux set-hook -g session-closed[100] "run-shell 'if [ \"\$1\" = \"$CURRENT_SESSION\" ]; then tmux kill-window -t $POPUP_SESSION:$WINDOW_NAME 2>/dev/null || true; fi'"

# Create the popups session if it doesn't exist
if ! tmux has-session -t "$POPUP_SESSION" 2>/dev/null; then
  # Create session with the first window already having the correct name
  if [ -n "$COMMAND" ]; then
    tmux new-session -d -s "$POPUP_SESSION" -n "$WINDOW_NAME" -c "$CURRENT_PATH" "$COMMAND"
  else
    tmux new-session -d -s "$POPUP_SESSION" -n "$WINDOW_NAME" -c "$CURRENT_PATH"
  fi
  # Disable status bar for this session
  tmux set-option -t "$POPUP_SESSION" status off

  # Set up a hook to kill this popup window when the original window closes
  tmux set-hook -t $CURRENT_SESSION:$CURRENT_WINDOW window-unlinked[100] "run-shell 'tmux kill-window -t $POPUP_SESSION:$WINDOW_NAME 2>/dev/null || true'"

  # Launch popup immediately
  tmux popup -E -w 90% -h 90% -x C -y C "tmux attach-session -t $POPUP_SESSION"
  exit 0
fi

# Check if the window for this session+window already exists in popups session
if tmux list-windows -t "$POPUP_SESSION" -F "#{window_name}" | grep -q "^$WINDOW_NAME$"; then
  # Window exists, select it
  tmux select-window -t "$POPUP_SESSION:$WINDOW_NAME"
else
  if [ -n "$COMMAND" ]; then
    tmux new-window -t "$POPUP_SESSION" -n "$WINDOW_NAME" -c "$CURRENT_PATH" "$COMMAND"
  else
    tmux new-window -t "$POPUP_SESSION" -n "$WINDOW_NAME" -c "$CURRENT_PATH"
  fi

  # Set up a hook to kill this popup window when the original window closes
  tmux set-hook -t $CURRENT_SESSION:$CURRENT_WINDOW window-unlinked[100] "run-shell 'tmux kill-window -t $POPUP_SESSION:$WINDOW_NAME 2>/dev/null || true'"
fi

# Launch popup attached to the popups session
tmux popup -E -w 90% -h 90% -x C -y C "tmux attach-session -t $POPUP_SESSION"
