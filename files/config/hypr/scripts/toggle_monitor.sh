#!/usr/bin/env bash

MONITOR_ID=$1
case $MONITOR_ID in
"1")
    MONITOR="DP-3"
    CONFIG="DP-3,3840x2160,0x180,2"
    ;;
"2")
    MONITOR="DP-4"
    CONFIG="DP-4,3440x1440,1920x0,1"
    ;;
"3")
    MONITOR="HDMI-A-5"
    CONFIG="HDMI-A-5,3840x2160,5360x0,2.5"
    ;;
*)
    echo "Invalid monitor ID: $MONITOR_ID"
    exit 1
    ;;
esac

# Check if monitor is currently active
if hyprctl monitors | grep -q "Monitor $MONITOR"; then
    # Monitor is active, disable it
    hyprctl keyword monitor "$MONITOR,disable"
    echo "Disabled monitor $MONITOR_ID"
else
    # Monitor is disabled, enable it
    hyprctl keyword monitor "$CONFIG"
    echo "Enabled monitor $MONITOR_ID"
fi
