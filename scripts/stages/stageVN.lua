local allows_pause = true

local gui

-- Local variables:
-- active background, previous background
-- active characters

local function load() -- Call this function when you want to switch to this stage
	-- Reinitalize the GUI
	gui = require('scripts/gui/Gspot')
	gui_font = love.graphics.newFont(72)
	love.graphics.setFont(gui_font)
	love.graphics.setColor(255, 192, 0, 128) 
end

local function update(dt) 
	print("Junk")
end

local function draw() 
	print("Junk")
	-- Draw backgrounds, possibly in transition from a previous state
	-- Draw characters, possibly in transition from a previous state
	-- Render some text with renderText, which is locally required
	-- Draw text advancement GUI
end

local function unload()
	-- Set stuff to nil if we don't need to keep it in limbo. 
	-- Unload only AFTER we stop updating the scene, otherwise errors can happen.
end

local M = { allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw }
return M