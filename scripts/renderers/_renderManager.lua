
local standard_renderers = {
	bkg = require("scripts/renderers/renderBkg"),
	char = require("scripts/renderers/renderChar"),
	fade = require("scripts/renderers/renderFade"),
	text = require("scripts/renderers/renderText"),
}

local cam = require("scripts/renderers/_camera")
local adv = require("scripts/renderers/renderAdvance")

local busy = false
local action_queue = {}
local last_advance

local function load()
	last_advance = love.timer.getTime()
	for k,v in pairs(standard_renderers) do
		v.load()
	end
	adv.load()
end

local function hurry()
	-- Forces all the renderers to hurry.
	for k,v in pairs(standard_renderers) do
		if v.busy then
			v.hurry()
		end
	end
	-- Artifically sets the last_advance time to cause the next action_queue element to trigger.
	if action_queue[1].meta.wait ~= -1 then last_advance = love.timer.getTime() - action_queue[1].meta.wait - 60.0 end
end

--[[ 
	Unlike a scene's advance() function, _renderManager.advance(queue) adds a series of calls to _renderManager's 
		action_queue that it will execute before indicating that it's not busy (i.e. before the player can advance again.)
	I decided on this implementation so that we don't need to be independently update()-ing the scene itself
		to handle delayed functions. _renderManager already gets update(dt) from main.lua so it's more natural
		to include the countdown functionality here.
	This way the active scene in a stage is state-like rather than an active process.
]]
local function advance(queue)
	action_queue = queue
	busy = true
	for i = 1,#action_queue[1].funcs do
		-- Unpacks a table into a series of arguments. See documentation here: https://www.lua.org/pil/5.1.html
		action_queue[1].funcs[i](unpack(action_queue[1].args[i]))
	end
	last_advance = love.timer.getTime()
end

local function update(dt)
	-- print(#action_queue)
	-- Handling cases where we want to stagger various renderer calls over time.
	if #action_queue > 1 and action_queue[1].meta.wait ~= -1 and love.timer.getTime() >= action_queue[1].meta.wait + last_advance then
		local new_queue = {}
		for i = 2,#action_queue do
			table.insert(new_queue,action_queue[i])
		end
		advance(new_queue)
	end
	-- Update each standard renderer and check if it's still busy afterwards.
	local busy_this_frame = false
	for k,v in pairs(standard_renderers) do
		v.update(dt)
		if v.get_busy() then
			busy_this_frame = true
		end
	end 
	cam.update(dt)
	if cam.get_busy() then busy_this_frame = true end
	-- Edge case where no renderers are busy but we're waiting for the next cue item
	if action_queue[1] then if action_queue[1].meta.wait ~= -1 then busy_this_frame = true end end
	busy = busy_this_frame
	adv.update(dt,busy)
end

local function get_busy()
	return busy
end

M = { r = standard_renderers, adv = adv, cam = cam, load = load, update = update, get_busy = get_busy, queue = queue, hurry = hurry, advance = advance }
return M
