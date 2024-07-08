#!/usr/bin/env bash

COMMAND_OUTPUT=$(hyprctl monitors)
SEARCH_STRING="LG TV"

if grep -q "$SEARCH_STRING" <<<"$COMMAND_OUTPUT"; then
    hyprctl keyword monitor HDMI-A-5,disabled
    notify-send -t 2000 -e "TV disabled"
else
    hyprctl keyword monitor HDMI-A-5,3840x2160,6000x0,1
    notify-send -t 2000 -e "TV enabled"
fi
