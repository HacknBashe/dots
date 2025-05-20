#!/bin/bash

current_date=$(date "+%a %d %b %I:%M %p")

sketchybar \
  --add item clock right \
  --set clock label="${current_date}" \
  icon.drawing=off \
  updates=on \
  update_freq=10 \
  script="$PLUGIN_DIR/clock.sh" \
