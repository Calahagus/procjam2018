local allows_pause = true

local gui = require('scripts/gui/Gspot')

local function load() -- Call this function when you want to switch to this stage
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

local M = { allows_pause = allows_pause, load = load, update = update, draw = draw }
return M