local allows_pause = true

local gui

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
	love.graphics.print("heya dude")
end

local M = { allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw }
return M