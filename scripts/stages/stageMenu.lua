local allows_pause = false

local gui = require('scripts/libraries/Gspot')

-- Fixes that need to be called every time we instantiate Gspot for mouse changes in 0.10
love.mousepressed = function(x, y, button)
	gui:mousepress(x, y, button) -- pretty sure you want to register mouse events
end
love.mousereleased = function(x, y, button)
	gui:mouserelease(x, y, button)
end

local function load()
	-- Reinitalize the GUI
	-- gui = require('scripts/gui/Gspot')
	gui_font = love.graphics.newFont(72)
	love.graphics.setFont(gui_font)
	love.graphics.setColor(255, 192, 0, 128) 

	local button_start = gui:button('Play', {x = 128, y = 128, w = 128, h = 128})
	button_start.click = function(this)
		load_stage(stage_vn)
	end

	-- Options button

	-- Credits button

	-- Quit button

end

local function update(dt)
	gui:update(dt)
end

local function draw() 
	gui:draw()
end

local function keypressed(key)
	-- Do nuttin'
end

local function keyreleased(key)
	-- Do nuttin'
end

local function unload()
	-- Set stuff to nil if we don't need to keep it in limbo. 
	-- Unload only AFTER we stop updating the scene, otherwise errors can happen.
	gui = nil
end

local M = { allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw, keypressed = keypressed, keyreleased = keyreleased }
return M