#!/bin/bash

sketchybar \
  --add item weather.temp right \
  --set weather.temp label="N/A" \
  label.font.size=20 \
  icon.drawing=off \
  updates=on \
  update_freq=10 \
  script="$PLUGIN_DIR/weather.sh"

sketchybar \
  --add item weather.icon right
