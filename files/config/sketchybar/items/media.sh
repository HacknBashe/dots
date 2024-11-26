#!/bin/bash

sketchybar --add item media.label right \
  --set media.label label.color=$ACCENT_COLOR \
  label.max_chars=6 \
  scroll_texts=on \
  icon.drawing=off0 \
  background.drawing=off \
  click_script="open -a Spotify"

sketchybar --add item media.icon right \
  --set media.icon label.drawing=off \
  icon.padding_left=0 \
  icon=󰎇 \
  icon.color=$ACCENT_COLOR \
  background.drawing=off \
  click_script="open -a Spotify"

sketchybar --add bracket media media.label media.icon \
  --set media script="$PLUGIN_DIR/media.sh" \
  --subscribe media media_change \
