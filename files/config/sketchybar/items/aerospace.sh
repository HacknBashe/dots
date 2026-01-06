#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Add event subscription
sketchybar --add event aerospace_workspace_change

# Detect connected monitors
MONITORS=$(aerospace list-monitors --format '%{monitor-id}' | sort -n)

# Define workspace icons
declare -A WORKSPACE_ICONS=(
	["1"]="󱈹"
	["2"]="󰚩"
	["3"]=""
	["4"]=""
	["5"]="󰦬"
	["6"]="󱁤"
	["7"]=""
	["8"]="󰪶"
	["9"]=""
	["10"]="󰍩"
	["M"]="󰨜"
	["N"]="󰠮"
	["P"]="󰎆"
)

# Canonical workspace order
WORKSPACE_ORDER=(1 2 3 4 5 6 7 8 9 10 M N P)

# Step 1: Create all items grouped by monitor (for correct visual order)
PREV_MONITOR=""
for monitor in $MONITORS; do
	# Add spacer before this monitor (except for first monitor)
	if [ -n "$PREV_MONITOR" ]; then
		sketchybar --add item "space.${PREV_MONITOR}_${monitor}" left \
			--set "space.${PREV_MONITOR}_${monitor}" \
			width=10 \
			drawing=on \
			background.drawing=off \
			background.padding_left=0 \
			background.padding_right=0 \
			padding_left=0 \
			padding_right=0 \
			icon.drawing=off \
			icon.padding_left=0 \
			icon.padding_right=0 \
			label.drawing=off \
			label.padding_left=0 \
			label.padding_right=0
	fi

	# Create empty monitor placeholder for this monitor
	# Make it match workspace item dimensions for consistent spacing
	sketchybar --add item "empty_monitor_$monitor" left \
		--set "empty_monitor_$monitor" \
		icon="" \
		icon.padding_left=4 \
		icon.padding_right=4 \
		label.drawing=off \
		background.drawing=off \
		background.padding_left=4 \
		background.padding_right=4 \
		drawing=off

	# Create all workspace items for this monitor
	for ws in "${WORKSPACE_ORDER[@]}"; do
		sketchybar --add item "workspace_${ws}_mon${monitor}" left \
			--set "workspace_${ws}_mon${monitor}" \
			icon="${WORKSPACE_ICONS[$ws]}" \
			icon.padding_left=4 \
			icon.padding_right=4 \
			icon.color="$FG_COLOR" \
			icon.highlight_color="$SELECTED_COLOR" \
			label.drawing=off \
			background.drawing=off \
			background.padding_left=4 \
			background.padding_right=4 \
			click_script="aerospace workspace $ws" \
			script="$PLUGIN_DIR/aerospace_workspace.sh" \
			--subscribe "workspace_${ws}_mon${monitor}" aerospace_workspace_change
	done

	PREV_MONITOR="$monitor"
done

# Step 2: Create brackets (one per monitor)
for monitor in $MONITORS; do
	# Build list of items for this monitor's bracket
	BRACKET_ITEMS=("empty_monitor_$monitor")
	for ws in "${WORKSPACE_ORDER[@]}"; do
		BRACKET_ITEMS+=("workspace_${ws}_mon${monitor}")
	done

	# Create bracket
	sketchybar --add bracket "monitor_group_$monitor" "${BRACKET_ITEMS[@]}" \
		--set "monitor_group_$monitor" \
		padding_left=0 \
		padding_right=0 \
		background.drawing=on \
		background.color="$BAR_COLOR" \
		background.corner_radius=8 \
		background.height=26 \
		background.padding_left=8 \
		background.padding_right=8
done

# Step 3: Create trigger item for empty monitor management
sketchybar --add item aerospace.empty_check left \
	--set aerospace.empty_check \
	drawing=off \
	script="$PLUGIN_DIR/aerospace_empty_monitors.sh" \
	--subscribe aerospace.empty_check aerospace_workspace_change
