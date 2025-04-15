local Swipe = {}
Swipe.__index = Swipe

-- Metadata
Swipe.name = "Swipe"
Swipe.version = "0.2"
Swipe.author = "Michael Mogenson, Nick Hackford"
Swipe.homepage = "https://github.com/mogenson/Swipe.spoon"
Swipe.license = "MIT - https://opensource.org/licenses/MIT"

local gesture = hs.eventtap.event.types.gesture
local doAfter = hs.timer.doAfter

function Swipe.new()
	local self = setmetatable({}, Swipe)
	self.cache = {
		id = 1,
		direction = nil,
		distance = 0,
		size = 0,
		touches = {},
		lastUpdateTime = nil,
		clear = function(cache)
			cache.touches = {}
			cache.size = 0
			cache.direction = nil
			cache.distance = 0
			cache.lastUpdateTime = nil
		end,
		none = function(cache, touches)
			local absent = true
			for _, touch in ipairs(touches) do
				absent = absent and (cache.touches[touch.identity] == nil)
			end
			return absent
		end,
		all = function(cache, touches)
			local present = true
			for _, touch in ipairs(touches) do
				present = present and (cache.touches[touch.identity] ~= nil)
			end
			return present
		end,
		set = function(cache, touches)
			cache:clear()
			for i, touch in ipairs(touches) do
				cache.touches[touch.identity] = {
					x = touch.normalizedPosition.x,
					y = touch.normalizedPosition.y,
					dx = 0,
					dy = 0,
				}
				cache.size = i
			end
			cache.lastUpdateTime = hs.timer.secondsSinceEpoch()
			cache.id = cache.id + 1
			return cache.id
		end,
		detect = function(cache, touches)
			local left, right, up, down = true, true, true, true
			local distance = { dx = 0, dy = 0 }
			local size = 0
			local currentTime = hs.timer.secondsSinceEpoch()
			local timeDelta = currentTime - (cache.lastUpdateTime or currentTime)
			cache.lastUpdateTime = currentTime

			for i, touch in ipairs(touches) do
				local id = touch.identity
				local x, y = touch.normalizedPosition.x, touch.normalizedPosition.y
				local dx, dy = x - assert(cache.touches[id]).x, y - assert(cache.touches[id]).y
				local abs_dx, abs_dy = math.abs(dx), math.abs(dy)
				local moved = (touch.phase == "moved")

				left = left and moved and (dx < 0) and (abs_dx > abs_dy)
				right = right and moved and (dx > 0) and (abs_dx > abs_dy)
				up = up and moved and (dy > 0) and (abs_dy > abs_dx)
				down = down and moved and (dy < 0) and (abs_dy > abs_dx)

				distance = { dx = distance.dx + dx, dy = distance.dy + dy }
				cache.touches[id] = { x = x, y = y, dx = dx, dy = dy }
				size = i
			end

			assert(cache.size == size)
			distance = { dx = distance.dx / size, dy = distance.dy / size }

			-- Calculate instantaneous speed (normalized units per second)
			local speed = math.sqrt(distance.dx * distance.dx + distance.dy * distance.dy) / timeDelta
			-- Minimum speed threshold (adjust this value as needed)
			local MIN_SPEED = 0.5

			local direction = nil
			if speed >= MIN_SPEED then
				if left and not (right or up or down) then
					direction = "left"
					if cache.direction == direction then
						cache.distance = cache.distance - distance.dx
					end
				elseif right and not (left or up or down) then
					direction = "right"
					if cache.direction == direction then
						cache.distance = cache.distance + distance.dx
					end
				elseif up and not (left or right or down) then
					direction = "up"
					if cache.direction == direction then
						cache.distance = cache.distance + distance.dy
					end
				elseif down and not (left or right or up) then
					direction = "down"
					if cache.direction == direction then
						cache.distance = cache.distance - distance.dy
					end
				end
			end

			if direction and (cache.direction ~= direction) then
				cache.direction = direction
				cache.distance = 0
			end

			return direction, cache.distance, cache.id
		end,
	}
	return self
end

function Swipe:start(fingers, callback)
	assert(fingers > 1)
	assert(callback)

	self.watcher = hs.eventtap.new({ gesture }, function(event)
		local type = event:getType(true)
		if type ~= gesture then
			return
		end
		local touches = event:getTouches()
		if #touches ~= fingers then
			return
		end

		if self.cache:none(touches) then
			local id = self.cache:set(touches)
		elseif self.cache:all(touches) then
			local direction, distance, id = self.cache:detect(touches)
			if direction then
				doAfter(0, function()
					callback(direction, distance, id)
				end)
			end
		end
	end)

	self.cache:clear()
	self.watcher:start()
end

function Swipe:stop()
	if self.watcher then
		self.watcher:stop()
		self.watcher = nil
	end
end

return Swipe
