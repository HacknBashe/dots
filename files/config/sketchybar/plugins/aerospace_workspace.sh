#!/run/current-system/sw/bin/bash

source "$CONFIG_DIR/colors.sh"

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
if [ -n "$FOCUSED_WORKSPACE" ]; then
	# FOCUSED_WORKSPACE provided (from exec-on-workspace-change callback)
	if [ "$ws" = "$FOCUSED_WORKSPACE" ]; then
		is_focused=true
	fi
else
	# No FOCUSED_WORKSPACE - query aerospace directly
	CURRENTLY_FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
	if [ "$ws" = "$CURRENTLY_FOCUSED" ]; then
		is_focused=true
	fi
fi

# Check 3: Has windows?
has_windows=false
if [ -n "$(aerospace list-windows --workspace "$ws" 2>/dev/null)" ]; then
	has_windows=true
fi

# Decision logic
if [ "$assigned_to_monitor" = "false" ]; then
	# Not on this monitor - hide
	sketchybar --set "$NAME" drawing=off icon.highlight=false icon.color="$FG_COLOR"
elif [ "$is_focused" = "true" ]; then
	# Focused workspace - show and highlight with cyan color
	sketchybar --set "$NAME" drawing=on icon.highlight=true icon.color="$SELECTED_COLOR"
elif [ "$has_windows" = "true" ]; then
	# Has windows but not focused - show without highlight
	sketchybar --set "$NAME" drawing=on icon.highlight=false icon.color="$FG_COLOR"
else
	# Empty and not focused - hide
	sketchybar --set "$NAME" drawing=off icon.highlight=false icon.color="$FG_COLOR"
fi
