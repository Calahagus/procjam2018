
local tween = require("scripts/libraries/tween")

local busy

local options = {
	font = nil,
	size = 12,
	speed = 25,
	speed_mult = 1.0,
}

local textbox = {
	img = love.graphics.newImage("/art/gui/textbox_enemydbg_green_small.png"),
	-- DEFERRED POST-DEMO1: have the advance icon be set on scene load by the enemy module
	active = false,
	scale = 4,
	pos = { x = 0, y = 0 },
	duration = 0.25, -- duration of tween in seconds
	tweener = nil,
}
local hide_target = {x = 96 * textbox.scale, y = 256 * textbox.scale}
local show_target = {x = 96 * textbox.scale, y = 64 * textbox.scale}

local fonts = {
	s = love.graphics.newFont(4 * textbox.scale),
	m = love.graphics.newFont(6 * textbox.scale),
	l = love.graphics.newFont(8 * textbox.scale),
}

local text = {
	target = "",
	current = "",
	progress = 0.0,
}

local function load() 
	-- Initialize the scene
	busy = false
	textbox.pos = copy.deep(hide_target)
	textbox.img:setFilter("nearest","nearest")
	for k,v in pairs(fonts) do
		v:setFilter("nearest","nearest")
	end
end

local function update(dt)
	local busy_this_frame = false
	text.progress = text.progress + (options.speed * options.speed_mult * dt)
	if text.progress > string.len(text.current) and text.progress > 0 then
		text.current = string.sub(text.target,1,math.floor(text.progress))
	end
	if text.progress < string.len(text.target) then busy_this_frame = true end
	if textbox.tweener ~= nil then
		if not textbox.tweener:update(dt) then -- t:update(dt) returns true if completed the tween
			busy_this_frame = true
		end
	end
	busy = busy_this_frame
end

local function draw(cam)
	if not cam then cam = {x=0,y=0} end
	if not cam.x then cam.x = 0 end
	if not cam.y then cam.y = 0 end
	love.graphics.draw(textbox.img,textbox.pos.x-cam.x,textbox.pos.y-cam.y,0,textbox.scale)
	love.graphics.setFont(fonts.l)
	love.graphics.printf(text.current,14*textbox.scale+textbox.pos.x-cam.x,14*textbox.scale+textbox.pos.y-cam.y,126*textbox.scale)
end

local function hurry()
	text.progress = string.len(text.target)
	-- TODO FOR DEMO1: also hurry the tween element
end

-- Renderer specific functions
local function show(speed)
	if speed == nil then speed = 1 end
	textbox.active = true
	textbox.tweener = tween.new(textbox.duration/speed,textbox.pos,show_target,"outBack")
end

local function hide(speed)
	if speed == nil then speed = 1 end
	textbox.active = false
	textbox.tweener = tween.new(textbox.duration/speed,textbox.pos,hide_target,"inBack")
end

-- TODO FOR DEMO1: add a sound for text to scroll in
-- TODO FOR DEMO1: add a name at the top of the textbox
local function new(new_text, new_options)
	if new_text == nil then new_text = "< NO STRING >" end
	if new_options == nil then new_options = {} end
	text.target = new_text
	text.current = ""
	text.progress = 0.0
	for k,v in pairs(options) do
		if new_options.k ~= nil then
			options.k = new_options.v
		end
	end
	if not textbox.active then
		show()
		text.progress = -1 * options.speed * textbox.duration -- Prevents text from showing up while the box is tweening
	end
end

local function new_line(text, new_options)
	-- DEFERRED POST-DEMO1
end

local function get_busy()
	return busy
end

local M = { get_busy = get_busy, load = load, update = update, draw = draw, hurry = hurry, show = show, hide = hide, new = new }
return M
