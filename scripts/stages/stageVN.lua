local bkg = require("scripts/renderers/renderBkg")
local chars = require("scripts/renderers/renderChar")
local text = require("scripts/renderers/renderText")

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
	bkg.update(dt)
	chars.update(dt)
	text.update(dt)
end

local function draw() 
	bkg.draw()
	chars.draw()
	text.draw()
	-- Draw text advancement GUI
	-- Draw fading out or fading in, if transitioning in or out of a scene
end

local function unload()
	-- Set stuff to nil if we don't need to keep it in limbo. 
	-- Unload only AFTER we stop updating the scene, otherwise errors can happen.
end

local M = { allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw }
return M