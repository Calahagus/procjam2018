local allows_pause = false

local gui = require('scripts/gui/Gspot')

-- Fixes that need to be called every time we instantiate Gspot for mouse changes in 0.10
love.mousepressed = function(x, y, button)
	gui:mousepress(x, y, button) -- pretty sure you want to register mouse events
end
love.mousereleased = function(x, y, button)
	gui:mouserelease(x, y, button)
end
love.wheelmoved = function(x, y)
	gui:mousewheel(x, y)
end

local function load()
	-- (Re)initalize the GUI
	gui_font = love.graphics.newFont(72)
	love.graphics.setFont(gui_font)
	love.graphics.setColor(255, 192, 0, 128) 

	local button_start = gui:button('Play', {x = 128, y = 128, w = 128, h = 128})
	button_start.click = function(this)
		load_stage(stage_vn)
	end
end

local function update(dt)
	gui:update(dt)
end

local function draw() 
	gui:draw()
end

local M = { allows_pause = allows_pause, load = load, update = update, draw = draw }
return M