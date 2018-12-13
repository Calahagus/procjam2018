
local busy

local active_bkg = { img = nil, scale = 1 }
local passive_bkg = { img = nil, scale = 1 }

local bkg_fade
local bkg_fade_speed

local default_scale = 4

local function load() 
	-- Initialize the scene
	busy = false
	active_bkg = { img = nil, scale = 1 }
	passive_bkg = { img = nil, scale = 1 }
	bkg_fade = 1.0
	bkg_fade_speed = 1.0
end

local function update(dt) 
	local busy_this_frame = false
	bkg_fade = math.min(bkg_fade + (1.0 * dt * bkg_fade_speed),1.0) 
	if bkg_fade < 1.0 then busy_this_frame = true end
	busy = busy_this_frame
end

local function draw(cam) 
	if not cam then cam = {x=0,y=0} end
	if not cam.x then cam.x = 0 end
	if not cam.y then cam.y = 0 end

	if passive_bkg.img ~= nil then
		love.graphics.setColor(255,255,255)
		love.graphics.draw(passive_bkg.img,0-cam.x,0-cam.y,0,passive_bkg.scale)
	end
	if active_bkg.img ~= nil then
		love.graphics.setColor(255,255,255,bkg_fade)
		love.graphics.draw(active_bkg.img,0-cam.x,0-cam.y,0,active_bkg.scale)
	end
	love.graphics.reset()
end

local function hurry()
	bkg_fade = 1.0
end

-- Renderer-specific functions
local function fade(new_bkg, bkg_scale, fade_speed)
	new_bkg:setFilter("nearest","nearest")
	if bkg_scale == nil then bkg_scale = default_scale end
	if fade_speed == nil then fade_speed = 1.0 end
	passive_bkg = active_bkg
	active_bkg = { img = new_bkg, scale = bkg_scale }
	bkg_fade = 0.0
	bkg_fade_speed = fade_speed
end

local function set(new_bkg, layer, bkg_scale)
	new_bkg:setFilter("nearest","nearest")
	if bkg_scale == nil then bkg_scale = default_scale end
	passive_bkg = active_bkg
	active_bkg = { img = new_bkg, scale = bkg_scale }
	bkg_fade = 1.0
end

local function get_busy()
	return busy
end

local M = { get_busy = get_busy, load = load, update = update, draw = draw, hurry = hurry, fade = fade, set = set }
return M