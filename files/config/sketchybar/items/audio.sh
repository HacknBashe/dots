#!/bin/bash

icon=$(if [ "$(SwitchAudioSource -c)" == "Jabra Link 390" ]; then echo "󰋋"; else echo "󰓃"; fi)
sketchybar \
  --add item audio left \
  --set audio script="$PLUGIN_DIR/audio_volume.sh" \
  icon=$icon \
  icon.padding_left=5 \
  icon.padding_right=5 \
  label.padding_right=5 \
  popup.height=30 \
  click_script="$PLUGIN_DIR/audio_toggle_output.sh" \
  --subscribe audio volume_change mouse.scrolled
