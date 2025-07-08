#!/usr/bin/env bash

current_device=$(/opt/homebrew/bin/SwitchAudioSource -c)

if [ "$current_device" == "MacBook Pro Speakers" ] && /opt/homebrew/bin/SwitchAudioSource -a | grep -q "Nick's AirPods Pro"; then
  /opt/homebrew/bin/SwitchAudioSource -t output -s "Nick's AirPods Pro"
  /opt/homebrew/bin/SwitchAudioSource -t input -s "Nick's AirPods Pro"
  sketchybar --set $NAME icon="󰋋"
else
  /opt/homebrew/bin/SwitchAudioSource -t output -s "MacBook Pro Speakers"
  /opt/homebrew/bin/SwitchAudioSource -t output -s "MacBook Pro Microphone"
  sketchybar --set $NAME icon="󰓃"
fi
