#!/bin/bash

STATE="$(echo "$INFO" | jq -r '."Player State"')"
if [ "$STATE" = "Playing" ]; then
  DETAILS="$(echo "$INFO" | jq -r '.Name + " - " + .Artist')"
  sketchybar --set $NAME label="$DETAILS" drawing=on
else
  sketchybar --set $NAME drawing=off
fi
