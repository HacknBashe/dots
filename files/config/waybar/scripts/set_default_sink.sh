#!/usr/bin/env bash

command_output=$(wpctl status)
search_string="Audio/Sink    alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo"

if grep -q "$search_string" <<<"$command_output"; then
    wpctl set-default $(wpctl status | grep -m 1 -A 6 "Sinks" | grep "Headset" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
    hyprctl notify -1 3000 "rgb(ff1ea3)" "󰋋  Headset set as default output device."
else
    wpctl set-default $(wpctl status | grep -m 1 -A 6 "Sinks" | grep "Soundbar" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
    hyprctl notify -1 3000 "rgb(ff1ea3)" "󰓃  Soundbar set as default output device."
fi
