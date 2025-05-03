#!/bin/bash

sketchybar --add item media.label right \
  --set media.label \
  label.max_chars=25 \
  scroll_texts=on \
  icon.drawing=off0 \
  background.drawing=off \
  click_script="open -a Spotify"

sketchybar --add item media.icon right \
  --set media.icon label.drawing=off \
  icon.padding_left=0 \
  icon.padding_right=0 \
  icon=󰎇 \
  background.drawing=off \
  click_script="open -a Spotify"

sketchybar --add bracket media media.label media.icon \
  --set media script="$PLUGIN_DIR/media.sh" \
  --subscribe media media_change \
