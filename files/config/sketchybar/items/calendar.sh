#!/bin/bash

sketchybar --add item calendar.time right \
  --set calendar.time \
  label.max_chars=5 \
  icon="󰃰" \
  background.drawing=off \
  click_script="open -a \"Google Calendar\""

sketchybar --add item calendar.event right \
  --set calendar.event \
  updates=on \
  update_freq=60 \
  script="$PLUGIN_DIR/calendar.sh" \
  label.max_chars=20 \
  scroll_texts=on \
  icon.drawing=off \
  background.drawing=off \
  click_script="open -a \"Google Calendar\""
