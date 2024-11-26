#!/bin/bash

STATE="$(echo "$INFO" | jq -r '.state')"
if [ "$STATE" = "playing" ]; then
  MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
  sketchybar --set media.label label="$MEDIA" drawing=on \
    --set media.icon drawing=on
else
  sketchybar --set media.label drawing=off \
    --set media.icon drawing=off
fi
