#!/bin/bash

if [ "$NAME" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    icon.highlight=true
else
  sketchybar --set "$NAME" \
    icon.highlight=false

  if [ -z "$(aerospace list-windows --workspace $NAME)" ]; then
    sketchybar --set "$NAME" \
      drawing=off
  else
    sketchybar --set "$NAME" \
      drawing=on
  fi
fi
