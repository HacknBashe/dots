#!/bin/bash

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
sketchybar --add item spotify left \
  --set spotify label.max_chars=20 \
  scroll_texts=on \
  icon.padding_left=0 \
  icon=󰎇 \
  background.drawing=off \
  click_script="open -a Spotify" \
  script="$PLUGIN_DIR/spotify.sh" \
  --add event spotify_change $SPOTIFY_EVENT \
  --subscribe spotify spotify_change
