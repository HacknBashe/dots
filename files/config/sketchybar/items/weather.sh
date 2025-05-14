#!/bin/bash

sketchybar \
  --add item weather.temp right \
  --set weather.temp label="N/A" \
  updates=on \
  update_freq=10 \
  script="$PLUGIN_DIR/weather.sh"
