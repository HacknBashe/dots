#!/bin/bash

if [ "$SENDER" = "volume_change" ]; then
  sketchybar --set audio label="$INFO%"
fi

if [ "$SENDER" = "mouse.scrolled" ]; then
  delta=$(echo "$INFO" | jq -r '.delta')
  if [ $delta -lt 0 ]; then
    osascript -e "set volume output volume (output volume of (get volume settings) + 5)"
  elif [ $delta -gt 0 ]; then
    osascript -e "set volume output volume (output volume of (get volume settings) - 5)"
  fi
fi
