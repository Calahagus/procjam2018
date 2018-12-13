
local since_last_busy
local draw_delay = 0.5

local scale = 3

local sin_mult = math.pi / 2
local sin_xshift = -math.pi / 3
local sin_yshift = 1.0
-- DEFERRED POST-DEMO1: have the advance icon be set on scene load by the enemy module
local advance_icon = love.graphics.newImage("/art/gui/advanceicon_enemydbg.png")

local function load() 
	since_last_busy = love.timer.getTime()
	advance_icon:setFilter("nearest","nearest")
end

--[[
	Unlike other renderers, renderAdvance has a unique update call.
	renderAdvance needs to be told by _renderManager whether the other renderers are busy at the moment, and adjust its draw function 
]]
local function update(dt,busy) 
	if busy then since_last_busy = love.timer.getTime() end
end

-- Calculates the alpha value for the advancement icon and draws it on screen.
local function draw(camera) 
	if camera.x == nil then camera.x = 0 end
	if camera.y == nil then camera.y = 0 end
	if love.timer.getTime() > since_last_busy + draw_delay then
		local alpha = (math.sin((love.timer.getTime() - (since_last_busy + draw_delay) + sin_xshift ) * sin_mult) + sin_yshift) / (sin_yshift + 1)
		love.graphics.setColor(255,255,255,alpha)
		love.graphics.draw(advance_icon, love.graphics.getWidth()-(32*scale), love.graphics.getHeight()-(32*scale), 0, scale)
		love.graphics.reset()
	end
end

local M = { load = load, update = update, draw = draw, advance_icon = advance_icon }
return M