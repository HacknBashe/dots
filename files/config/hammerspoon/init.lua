local current_id, threshold
Swipe = hs.loadSpoon("Swipe")
Swipe:start(3, function(direction, distance, id)
	if id == current_id then
		if distance > threshold then
			threshold = math.huge -- only trigger once per swipe

			if direction == "left" then
				hs.execute(
					"/opt/homebrew/bin/aerospace list-workspaces --monitor focused --empty no | /opt/homebrew/bin/aerospace workspace next"
				)
			elseif direction == "right" then
				hs.execute(
					"/opt/homebrew/bin/aerospace list-workspaces --monitor focused --empty no | /opt/homebrew/bin/aerospace workspace prev"
				)
			end
		end
	else
		current_id = id
		threshold = 0.2 -- swipe distance > 20% of trackpad
	end
end)
