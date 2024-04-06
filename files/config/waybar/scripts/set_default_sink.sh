#!/usr/bin/env bash

command_output=$(wpctl status)
search_string="Audio/Sink    alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo"

if grep -q "$search_string" <<< "$command_output"; then
    wpctl set-default $(wpctl status | grep -m 1 -A 6 "Sinks" | grep "Soundbar" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
    notify-send -t 2000 -e "Soundbar set as default output device."
else
    wpctl set-default $(wpctl status | grep -m 1 -A 6 "Sinks" | grep "Headset" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
    notify-send -t 2000 -e "Headset set as default output device."
fi
