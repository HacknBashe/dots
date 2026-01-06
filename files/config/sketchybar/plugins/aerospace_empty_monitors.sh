#!/run/current-system/sw/bin/bash

# For each monitor, check if any workspace is visible
for monitor in $(aerospace list-monitors --format '%{monitor-id}' | sort -n); do
	any_visible=false

	# Check all 13 workspaces for this monitor
	for ws in 1 2 3 4 5 6 7 8 9 10 M N P; do
		# Query sketchybar for item drawing state (first occurrence is geometry.drawing)
		item_drawing=$(sketchybar --query "workspace_${ws}_mon${monitor}" 2>/dev/null | grep '"drawing"' | head -1 | grep -o 'on\|off')

		if [ "$item_drawing" = "on" ]; then
			any_visible=true
			break
		fi
	done

	# Show empty placeholder only if no workspaces visible
	if [ "$any_visible" = "true" ]; then
		sketchybar --set "empty_monitor_$monitor" drawing=off
	else
		sketchybar --set "empty_monitor_$monitor" drawing=on
	fi
done
