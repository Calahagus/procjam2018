
local busy

-- TODO POST-DEMO1: update this to use tween library
local fade_target -- 1 = go to black, -1 = go to clear
local fade_speed
local fade_tween

local function load(start_black) 
	if start_black == nil then start_black = true end
	-- Initialize the renderer
	if start_black then
		fade_target = 1
		fade_speed = 1.0
		fade_tween = 1.0
	end
end

local function update(dt)
	fade_tween = fade_tween + fade_target * fade_speed * dt
	fade_tween = math.max(fade_tween,0.0)
	fade_tween = math.min(fade_tween,1.0)
	if fade_tween > 0.0 and fade_tween < 1.0 then 
		busy = true 
	else 
		busy = false 
	end
end

local function draw()
	love.graphics.setColor(0,0,0,fade_tween)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	if fade_tween > 0.8 then
		love.graphics.setColor(255,255,255,(fade_tween-0.8)*5)
		love.graphics.printf("ProcGen Rhythm Game",0,love.graphics.getHeight()/2-48,1000,"center")
		love.graphics.printf("Demo 1: Renderer + Rhythm Sync Test",0,love.graphics.getHeight()/2,1000,"center")
		love.graphics.printf("7 December 2018",0,love.graphics.getHeight()/2+48,1000,"center")
	end
	love.graphics.reset()
end

local function hurry()
	set_fade(fade_target)
end

-- Renderer-specific functions
local function fade(target, speed)
	if target == nil then fade_target = 1 else fade_target = target end
	if speed == nil then fade_speed = 1.0 else fade_speed = speed end
end

local function set_fade(target)
	if target == nil then fade_target = 1 else fade_target = target end
	if fade_target then fade_tween = 100 else fade_tween = 0 end
end

local function get_busy()
	return busy
end

local M = { load = load, update = update, draw = draw, get_busy = get_busy, hurry = hurry, enter = enter, exit = exit, fade = fade, set_fade = set_fade }
return M