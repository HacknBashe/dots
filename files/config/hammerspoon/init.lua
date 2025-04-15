hs.loadSpoon("Voice")

local three_finger_id, three_finger_threshold
Swipe = hs.loadSpoon("Swipe")
local threeFingerSwipe = Swipe.new()
threeFingerSwipe:start(3, function(direction, distance, id)
	if id == three_finger_id then
		if distance > three_finger_threshold then
			three_finger_threshold = math.huge

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
		three_finger_id = id
		three_finger_threshold = 0.15
	end
end)

local two_finger_id, two_finger_threshold
local twoFingerSwipe = Swipe.new()
twoFingerSwipe:start(2, function(direction, distance, id)
	if id == two_finger_id then
		if distance > two_finger_threshold then
			two_finger_threshold = math.huge

			local app = hs.window.focusedWindow()
			if app and app:application():name() == "Slack" then
				if direction == "right" then
					hs.eventtap.keyStroke({ "cmd" }, "[")
				elseif direction == "left" then
					hs.eventtap.keyStroke({ "cmd" }, "]")
				end
			end

			if app and app:application():name() == "Cursor" then
				if direction == "right" then
					hs.eventtap.keyStroke({}, "escape")
					hs.eventtap.keyStroke({ "ctrl" }, "o")
				elseif direction == "left" then
					hs.eventtap.keyStroke({}, "escape")
					hs.eventtap.keyStroke({ "ctrl" }, "i")
				end
			end
		end
	else
		two_finger_id = id
		two_finger_threshold = 0.15
	end
end)
