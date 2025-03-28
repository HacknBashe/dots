hs.loadSpoon("Voice")

local current_id, threshold
Swipe = hs.loadSpoon("Swipe")
local threeFingerSwipe = Swipe.new()
threeFingerSwipe:start(3, function(direction, distance, id)
	if id == current_id then
		if distance > threshold then
			threshold = math.huge

			if direction == "left" then
				hs.execute(
					"/run/current-system/sw/bin/aerospace list-workspaces --monitor focused --empty no | /run/current-system/sw/bin/aerospace workspace next"
				)
			elseif direction == "right" then
				hs.execute(
					"/run/current-system/sw/bin/aerospace list-workspaces --monitor focused --empty no | /run/current-system/sw/bin/aerospace workspace prev"
				)
			end
		end
	else
		current_id = id
		threshold = 0.15
	end
end)

local slack_current_id, slack_threshold
local twoFingerSwipe = Swipe.new()
twoFingerSwipe:start(2, function(direction, distance, id)
	if id == slack_current_id then
		if distance > slack_threshold then
			slack_threshold = math.huge

			local app = hs.window.focusedWindow()
			if app and app:application():name() == "Slack" then
				if direction == "right" then
					hs.eventtap.keyStroke({ "cmd" }, "[")
				elseif direction == "left" then
					hs.eventtap.keyStroke({ "cmd" }, "]")
				end
			end
		end
	else
		slack_current_id = id
		slack_threshold = 0.15
	end
end)
