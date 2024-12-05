#!/usr/bin/env bash

current_device=$(SwitchAudioSource -c)

device_1="Jabra Link 390"
device_2="MacBook Pro Speakers"

if [ "$current_device" == "$device_1" ]; then
  SwitchAudioSource -t output -s "$device_2"
  sketchybar --set $NAME icon="󰓃"
else
  SwitchAudioSource -t output -s "$device_1"
  sketchybar --set $NAME icon="󰋋"
fi
