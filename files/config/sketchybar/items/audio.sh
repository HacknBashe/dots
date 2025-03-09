#!/bin/bash

icon=$(if [ "$(SwitchAudioSource -c)" == "Jabra Link 390" ]; then echo "󰋋"; else echo "󰓃"; fi)
sketchybar \
  --add item audio right \
  --set audio script="$PLUGIN_DIR/volume.sh" \
  icon=$icon \
  icon.padding_left=5 \
  icon.padding_right=5 \
  label.padding_right=5 \
  popup.height=30 \
  click_script="$PLUGIN_DIR/toggle_audio_output.sh" \
  --subscribe audio volume_change

sketchybar --add slider audio.slider right \
  --set audio.slider script="$PLUGIN_DIR/volume_slider.sh" \
  slider.percentage=50 \
  background.color=0x00000000 \
  background.height=16 \
  padding_left=20 \
  icon.padding_left=0 \
  icon.padding_right=0 \
  slider.highlight_color=0xffffffff \
  slider.background.height=5 \
  slider.width=40 \
  slider.knob=⬤ \
  click_script="$PLUGIN_DIR/volume_slider.sh" \
  --subscribe audio.slider volume_change
