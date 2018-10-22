local busy

local active_bkg
local bkg_fade
local passive_bkg

local function load() 
	-- Initialize the scene
	busy = false
	active_bkg = nil
	passive_bkg = nil
	bkg_fade = 100
end

local function unload() 
	-- clear the scene
end

local function update(dt) 
	print("Junk")
end

local function draw() 
	print("Junk")
end

-- hurry() tells the renderer to skip doing any sort of fancy crap, and go right to an unbusy state.
local function hurry()
	print("Junk")
end

-- Renderer-specific functions
local function enter(image, fade_speed)

end

local function exit(image, fade_speed)

end

local M = { busy = busy, load = load, update = update, draw = draw, enter, exit }
return M