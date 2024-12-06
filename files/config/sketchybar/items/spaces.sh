#!/bin/bash

# Add event to subscribe
sketchybar --add event aerospace_workspace_change

# Define your spaces with names and corresponding Nerd Font icons
# SPACES=("home:" "web:󰖟" "code:" "chat:󰍩" "music:󰎆")
SPACES=("1:󱈹" "2:󰃖" "3:" "4:" "5:󰺵" "6:󰖟" "7:󱁤" "8:󰽉" "9:" "10:󰒱" "M:󰨜" "N:󰠮" "P:󰓇")

# Add and configure spaces
for SPACE in "${SPACES[@]}"; do
  WORKSPACE_NAME=${SPACE%%:*} # Extract name (everything before ':')
  ICON=${SPACE##*:}           # Extract icon (everything after ':')

  # Add and set space
  sketchybar --add item "$WORKSPACE_NAME" left \
    --subscribe "$WORKSPACE_NAME" aerospace_workspace_change \
    --set "$WORKSPACE_NAME" \
    icon="$ICON" \
    click_script="aerospace workspace $WORKSPACE_NAME" \
    script="$PLUGIN_DIR/aerospace.sh $WORKSPACE_NAME"
done
