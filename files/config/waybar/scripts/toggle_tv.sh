#!/usr/bin/env bash

COMMAND_OUTPUT=$(hyprctl monitors)
SEARCH_STRING="LG TV"

if grep -q "$SEARCH_STRING" <<<"$COMMAND_OUTPUT"; then
    hyprctl keyword monitor HDMI-A-5,disabled
    hyprctl notify -1 3000 "rgb(ff1ea3)" "󰠺  TV Disabled"
else
    hyprctl keyword monitor HDMI-A-5,3840x2160,6000x0,1
    hyprctl notify -1 3000 "rgb(ff1ea3)" "󰟴  TV Enabled"
fi
