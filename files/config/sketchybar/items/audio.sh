#!/bin/bash

icon=$(if [ "$(SwitchAudioSource -c)" == "Razer Barracuda Pro 2.4" ]; then echo "󰋋"; else echo "󰓃"; fi)
sketchybar \
  --add item audio right \
  --set audio icon=$icon \
  icon.padding_right=8 \
  label.drawing=off \
  popup.height=30 \
  click_script="~/.local/bin/toggle_audio_output.sh"
