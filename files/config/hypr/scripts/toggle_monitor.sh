#!/usr/bin/env bash

# Source monitor configuration from Nix-generated file
source ~/.config/hypr/monitor-vars.sh

MONITOR_ID=$1

# Dynamic variable expansion to get MONITORn_NAME and MONITORn_CONFIG
NAME_VAR="MONITOR${MONITOR_ID}_NAME"
CONFIG_VAR="MONITOR${MONITOR_ID}_CONFIG"

MONITOR="${!NAME_VAR}"
CONFIG="${!CONFIG_VAR}"

if [[ -z "$MONITOR" ]]; then
	echo "Invalid monitor ID: $MONITOR_ID"
	exit 1
fi

# Check if monitor is currently active
if hyprctl monitors | grep -q "Monitor $MONITOR"; then
	hyprctl keyword monitor "$MONITOR,disable"
	echo "Disabled monitor $MONITOR_ID ($MONITOR)"
else
	hyprctl keyword monitor "$CONFIG"
	echo "Enabled monitor $MONITOR_ID ($MONITOR)"
fi
