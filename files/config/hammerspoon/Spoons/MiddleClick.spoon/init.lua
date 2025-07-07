local obj = {}
obj.__index = obj

obj.name = "MiddleClick"
obj.version = "1.0"
obj.author = "nhackford"
obj.license = "MIT"
obj.homepage = "https://github.com/nhackford"

-- Internal variables
local tapWatcher = nil
local lastTapTime = 0
local doubleTapThreshold = 0.3
local minTapInterval = 0.1 -- Minimum time between taps to avoid noise
local debounceTimer = nil
local tapTimer = nil
local lastTouchCount = 0

function obj:init()
	-- Start the spoon right after initialization
	hs.timer.doAfter(0.1, function()
		self:start()
	end)
end

function obj:start()
	if tapWatcher then
		tapWatcher:stop()
	end

	-- Watch for gesture events and detect tap patterns
	tapWatcher = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(e)
		local touches = e:getTouches()
		local touchCount = touches and #touches or 0

		-- Detect a "tap" as: finger lifted after being down
		if lastTouchCount == 1 and touchCount == 0 then
			-- Use debounce timer to prevent rapid firing
			if debounceTimer then
				debounceTimer:stop()
			end

			debounceTimer = hs.timer.doAfter(minTapInterval, function()
				local currentTime = hs.timer.secondsSinceEpoch()
				local timeDiff = lastTapTime > 0 and (currentTime - lastTapTime) or 999

				-- Check if this is a double tap
				if lastTapTime > 0 and timeDiff <= doubleTapThreshold then
					-- Double tap detected - fire middle click
					hs.eventtap.middleClick(hs.mouse.absolutePosition())
					lastTapTime = 0

					if tapTimer then
						tapTimer:stop()
						tapTimer = nil
					end
				else
					-- First tap - record the time
					lastTapTime = currentTime

					if tapTimer then
						tapTimer:stop()
					end
					tapTimer = hs.timer.doAfter(doubleTapThreshold + 0.1, function()
						lastTapTime = 0
						tapTimer = nil
					end)
				end

				debounceTimer = nil
			end)
		end

		lastTouchCount = touchCount
		return false
	end)

	tapWatcher:start()
	return self
end

function obj:stop()
	if tapWatcher then
		tapWatcher:stop()
		tapWatcher = nil
	end

	if tapTimer then
		tapTimer:stop()
		tapTimer = nil
	end

	if debounceTimer then
		debounceTimer:stop()
		debounceTimer = nil
	end

	return self
end

return obj
