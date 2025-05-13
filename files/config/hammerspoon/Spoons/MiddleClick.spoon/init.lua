local obj = {}
obj.__index = obj

obj.name = "MiddleClick"
obj.version = "1.0"
obj.author = "nhackford"
obj.license = "MIT"
obj.homepage = "https://github.com/nhackford"

-- Internal variables
local gestureWatcher = nil
local clickWatcher = nil
local threeFingerDown = false
local clickLocation = nil

function obj:init()
	-- Start the spoon right after initialization
	hs.timer.doAfter(0.1, function()
		self:start()
	end)
end

function obj:start()
	if gestureWatcher then
		gestureWatcher:stop()
	end

	if clickWatcher then
		clickWatcher:stop()
	end

	-- Watch for three-finger touches
	gestureWatcher = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(e)
		local touches = e:getTouches()
		if touches and #touches == 3 then
			-- Only check phase if event properties is available
			local phase = nil
			local success = pcall(function()
				phase = e:getProperty(hs.eventtap.event.properties.gesturePhase)
			end)

			if success and phase then
				if phase == hs.eventtap.event.phases.began then
					threeFingerDown = true
					clickLocation = hs.mouse.absolutePosition()
				elseif phase == hs.eventtap.event.phases.ended then
					threeFingerDown = false
				end
			else
				-- If we can't detect phases, just use touch count as indicator
				threeFingerDown = true
				clickLocation = hs.mouse.absolutePosition()

				-- Reset after a short delay
				hs.timer.doAfter(0.3, function()
					threeFingerDown = false
				end)
			end
		end
		return false
	end)

	-- Watch for click events that might happen while three fingers are down
	clickWatcher = hs.eventtap.new({
		hs.eventtap.event.types.leftMouseDown,
		hs.eventtap.event.types.leftMouseUp,
	}, function(e)
		if threeFingerDown then
			local eventType = e:getType()
			if eventType == hs.eventtap.event.types.leftMouseDown then
				return true -- Cancel the regular click
			elseif eventType == hs.eventtap.event.types.leftMouseUp then
				if clickLocation then
					hs.eventtap.middleClick(clickLocation)
				end
				return true
			end
		end
		return false
	end)

	-- Start the watchers
	gestureWatcher:start()
	clickWatcher:start()

	return self
end

function obj:stop()
	if gestureWatcher then
		gestureWatcher:stop()
		gestureWatcher = nil
	end

	if clickWatcher then
		clickWatcher:stop()
		clickWatcher = nil
	end

	return self
end

return obj
