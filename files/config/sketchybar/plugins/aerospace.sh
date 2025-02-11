#!/bin/bash

if [ "$NAME" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    background.border_width=1 \
    background.border_color=0xffffffff
else
  sketchybar --set "$NAME" \
    background.border_width=0 \
    background.border_color=0xff262626

  if [ -z "$(aerospace list-windows --workspace $NAME)" ]; then
    sketchybar --set "$NAME" \
      drawing=off
  else
    sketchybar --set "$NAME" \
      drawing=on
  fi
fi
