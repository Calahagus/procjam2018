local bkg = require("scripts/renderers/renderBkg")
local chars = require("scripts/renderers/renderChar")
local text = require("scripts/renderers/renderText")

local allows_pause = true

local gui = require('scripts/libraries/Gspot')

local scene -- Initalizing the scene variable

-- Fixes that need to be called every time we instantiate Gspot for mouse changes in 0.10
love.mousepressed = function(x, y, button)
	gui:mousepress(x, y, button) -- pretty sure you want to register mouse events
end
love.mousereleased = function(x, y, button)
	gui:mouserelease(x, y, button)
end

-- Local variables:
-- active background, previous background
-- active characters

local function load() -- Call this function when you want to switch to this stage
	-- Reinitalize the GUI
	-- gui = require('scripts/gui/Gspot')
	gui_font = love.graphics.newFont(72)
	love.graphics.setFont(gui_font)
	love.graphics.setColor(255, 192, 0, 128) 

	-- set a scene
end

local function update(dt) 
	-- update the scene
end

local function draw() 
	bkg.draw()
	chars.draw()
	text.draw()
	-- Draw text advancement GUI
	-- Draw fading out or fading in, if transitioning in or out of a scene
end

local function keypressed(key)
	if key == "space" or key == "return" then
		scene.advance()
	end
end

local function keyreleased(key)
	-- Do nuttin'
end

local function unload()
	-- Set stuff to nil if we don't need to keep it in limbo. 
	-- Unload only AFTER we stop updating the scene, otherwise errors can happen.
end

local M = { allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw, keypressed = keypressed, keyreleased = keyreleased }
return M