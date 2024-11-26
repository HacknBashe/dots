#!/bin/bash

if [ "$SENDER" = "volume_change" ]; then
  sketchybar --set "$NAME" slider.percentage="$INFO"
elif [ "$BUTTON" = "left" ]; then
  osascript -e "set volume output volume $PERCENTAGE"
fi
