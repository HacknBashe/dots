#!/usr/bin/env bash

current_device=$(/opt/homebrew/bin/SwitchAudioSource -c)

device_1="MacBook Pro Speakers"
device_2="Razer Barracuda Pro 2.4"

if [ "$current_device" == "$device_1" ]; then
  /opt/homebrew/bin/SwitchAudioSource -t output -s "$device_2"
  sketchybar --set $NAME icon="󰋋"
else
  /opt/homebrew/bin/SwitchAudioSource -t output -s "$device_1"
  sketchybar --set $NAME icon="󰓃"
fi
