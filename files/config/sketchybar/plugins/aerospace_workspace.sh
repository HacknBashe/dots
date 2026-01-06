#!/run/current-system/sw/bin/bash

# Parse item name: "workspace_3_mon2" -> ws="3", mon="2"
ws="${NAME#workspace_}"
mon="${ws##*_mon}"
ws="${ws%_mon*}"

# Check 1: Is workspace assigned to this monitor?
assigned_to_monitor=false
if aerospace list-workspaces --monitor "$mon" 2>/dev/null | grep -q "^${ws}$"; then
	assigned_to_monitor=true
fi

# Check 2: Is focused?
is_focused=false
if [ "$ws" = "$FOCUSED_WORKSPACE" ]; then
	is_focused=true
fi

# Check 3: Has windows?
has_windows=false
if [ -n "$(aerospace list-windows --workspace "$ws" 2>/dev/null)" ]; then
	has_windows=true
fi

# Decision logic
if [ "$assigned_to_monitor" = "false" ]; then
	# Not on this monitor - hide
	sketchybar --set "$NAME" drawing=off icon.highlight=false
elif [ "$is_focused" = "true" ]; then
	# Focused workspace - show and highlight
	sketchybar --set "$NAME" drawing=on icon.highlight=true
elif [ "$has_windows" = "true" ]; then
	# Has windows but not focused - show without highlight
	sketchybar --set "$NAME" drawing=on icon.highlight=false
else
	# Empty and not focused - hide
	sketchybar --set "$NAME" drawing=off icon.highlight=false
fi
