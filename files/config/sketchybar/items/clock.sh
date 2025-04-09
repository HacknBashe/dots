#!/bin/bash

current_date=$(date "+%d %b %a %p %M %I")
date_parts=($current_date)

sketchybar \
  --add item clock.day right \
  --set clock.day label="${date_parts[0]}" \
  updates=on \
  update_freq=10 \
  script="$PLUGIN_DIR/clock.sh" \
  label.font.size=20 \
  icon.drawing=off

sketchybar \
  --add item clock.month right \
  --set clock.month label="${date_parts[1]}" \
  label.font.size=20 \
  icon.drawing=off

sketchybar \
  --add item clock.weekday right \
  --set clock.weekday label="${date_parts[2]}" \
  label.font.size=20 \
  icon.drawing=off

sketchybar \
  --add item clock.ampm right \
  --set clock.ampm label="${date_parts[3]}" \
  label.font.size=20 \
  icon.drawing=off

sketchybar \
  --add item clock.minutes right \
  --set clock.minutes label="${date_parts[4]}" \
  label.font.size=20 \
  icon.drawing=off

sketchybar \
  --add item clock.hours right \
  --set clock.hours label="${date_parts[5]}" \
  padding_left=20 \
  label.font.size=20 \
  icon.drawing=off
