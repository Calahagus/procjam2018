
local beatmath = require("scripts/beatMath")
local tween = require("scripts/libraries/tween")

local busy
local chars = {}
--[[
	chars = {
		local new_char = {
			file = module,
			pos = {
				state = { x = 400, y = 400 }, -- SCALE-RELATIVE
				tween = nil,
			},
			fade = {
				state = {0.0},
				tween = nil,
				exiting = false,
			},
			anim = {
				active = module.art[my_anim],
				passive = nil,
				started = love.timer.getTime(),
				state = {1.0},
				tween = nil,
			},
		},
	}
]]

local scale = 4

local function load() 
	-- Initialize the scene
	busy = false
	chars = {}
end

local function update(dt)
	local busy_this_frame = false
	for k,v in pairs(chars) do
		if v.pos.tween then if not v.pos.tween:update(dt) then busy_this_frame = true end end
		if v.fade.tween then if not v.fade.tween:update(dt) then busy_this_frame = true end end
		if v.anim.tween then if not v.anim.tween:update(dt) then busy_this_frame = true end end
		if v.fade.exiting and v.fade.state.val == 0.0 then v = nil end -- Garbage collection
	end
	busy = busy_this_frame
end

local function draw(cam)
	if not cam then cam = {x=0,y=0} end
	if not cam.x then cam.x = 0 end
	if not cam.y then cam.y = 0 end

	for k,v in pairs(chars) do
		if v.anim.passive then
			local anim = v.anim.passive
			local frame = ( beatmath.time_to_frames(love.timer.getTime() - v.anim.started, anim.fps) % #anim.frames ) + 1
			love.graphics.setColor(255,255,255,(1-v.anim.state.val)*v.fade.state.val)
			love.graphics.draw(anim.spritesheet,anim.quads[anim.frames[frame]],v.pos.state.x-cam.x,v.pos.state.y-cam.y,0,scale)
		end
		local anim = v.anim.active
		local frame = ( beatmath.time_to_frames(love.timer.getTime() - v.anim.started, anim.fps) % #anim.frames ) + 1
		love.graphics.setColor(255,255,255,v.anim.state.val*v.fade.state.val)
		love.graphics.draw(anim.spritesheet,anim.quads[anim.frames[frame]],v.pos.state.x-cam.x,v.pos.state.y-cam.y,0,scale)
		love.graphics.reset()
	end
end

-- hurry() tells the renderer to skip doing any sort of fancy crap, and go right to an unbusy state.
local function hurry()
	for k,v in pairs(chars) do
		while not (v.pos.tween:update(10) and v.fade.tween:update(10) and v.anim.tween:update(10)) do end
	end
end

-- Renderer-specific functions
local function enter(name,module,my_x,my_y,my_anim,enter_speed)
	if enter_speed == nil then enter_speed = 1.0 end
	local new_char = {
		file = module,
		pos = {
			state = { x = my_x, y = my_y },
			tween = nil,
		},
		fade = {
			state = {val = 0.0},
			tween = nil,
			exiting = false,
		},
		anim = {
			active = module.art[my_anim],
			passive = nil,
			started = love.timer.getTime(),
			state = {val = 1.0},
			tween = nil,
		},
	}
	chars[name] = new_char
	if enter_speed == -1 or enter_speed == 0 then
		chars[name].fade.state = {val = 1.0}
	else
		chars[name].fade.tween = tween.new(1.0/enter_speed,chars[name].fade.state,{val = 1.0},"outQuad") -- TEST: outQuad feels right?
	end
end

local function anim(name, target_anim, swap_speed)
	if swap_speed == nil then swap_speed = 1.0 end
	chars[name].anim.passive = chars[name].anim.active
	chars[name].anim.active = chars[name].file.art["target_anim"]
	chars[name].anim.state = {val = 0.0}
	chars[name].anim.tween = tween.new(1.0/swap_speed,chars[name].anim.state,{val = 1.0},"outQuad")
end

local function exit(name, exit_speed)
	if exit_speed == nil then exit_speed = 1.0 end
	chars[name].fade.exiting = true
	chars[name].fade.tween = tween.new(1.0/exit_speed,chars[name].fade.state,{val = 0.0},"inQuad")
end

local function move(name, target_x, target_y, move_speed)
	if move_speed == nil then move_speed = 1.0 end
	chars[name].pos.tween = tween.new(1.0/move_speed,chars[name].pos.state,{x = target_x, y = target_y},"inOutQuad")
end

local function say()
	-- DEFERRED POST-DEMO1
	-- convenience function, to animate a character (potentially until they're done speaking) AND tell textRender to do something 
end

local function get_busy()
	return busy
end

local M = { get_busy = get_busy, scale = scale, load = load, update = update, draw = draw, hurry = hurry, enter = enter, anim = anim, exit = exit, move = move }
return M
