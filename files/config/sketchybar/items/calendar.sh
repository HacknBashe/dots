#!/bin/bash

sketchybar --add item calendar.icon left \
  --set calendar.icon \
  label.drawing=off \
  icon.padding_left=0 \
  icon.padding_right=0 \
  icon="󰃰" \
  background.drawing=off \
  click_script="open -a \"Google Calendar\""

sketchybar --add item calendar.time left \
  --set calendar.time \
  label.max_chars=5 \
  icon.drawing=off \
  background.drawing=off \
  click_script="open -a \"Google Calendar\""

sketchybar --add item calendar.event left \
  --set calendar.event \
  updates=on \
  update_freq=60 \
  script="$PLUGIN_DIR/calendar.sh" \
  label.max_chars=25 \
  scroll_texts=on \
  icon.drawing=off \
  background.drawing=off \
  click_script="open -a \"Google Calendar\""
