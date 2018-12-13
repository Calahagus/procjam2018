
local tween = require("scripts/libraries/tween")
local busy = false

local cam = { 
	pos = {x = 0, y = 0}, 
	tween = nil,
}

local function update(dt)
	local busy_this_frame = false
	if cam.tween then if not cam.tween:update(dt) then busy_this_frame = true end end
end

local function move(new_x,new_y,speed)
	local target = {x = new_x, y = new_y}
	cam.tween = tween.new(1.0/speed,cam.pos,target,"inOutQuad")
end

local function get_pos()
	return cam.pos
end

local function get_busy()
	return busy
end

M = { update = update, get_pos = get_pos, get_busy = get_busy, move = move }
return M
