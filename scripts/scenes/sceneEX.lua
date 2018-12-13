
local rm = require("scripts/renderers/_renderManager")

local char_ex = require("scripts/chars/charEX")
local bkg_ex = love.graphics.newImage("art/bkgs/ex.png")

local q_index = 1
local action_queue = {}
--[[
	local action_queue = {
		set_of_actions_1 = {
			funcs = {
				f1, f2, f3, etc...
			},
			args = {
				{a1,a2}, {a1}, {}, etc...
			},
			meta = { 		applies to the whole set of actions
				wait = 2.0 			seconds to delay, or -1 = require advance prompt
			},
		},
		etc...
	}
]]

local function queue(new_funcs,new_args,new_meta)
	local new_element = {
		funcs = new_funcs,
		args = new_args,
		meta = new_meta,
	}
	table.insert(action_queue,new_element)
end

local function advance()
	local sub_queue = {}
	for i = q_index,#action_queue do
		table.insert(sub_queue,action_queue[i])
		if action_queue[i].meta.wait == -1 or action_queue[i+1] == nil then
			q_index = i + 1
			break
		end
	end
	rm.advance(sub_queue)
end

local function load() 
	-- setup the scene
	-- cue up fade-in, the first call
end

-- Scene-specific commands
local function example_1()
	queue({rm.r.bkg.enter,rm.r.text.new},{{bkg_ex},{"So this is it..."}},{wait = 2.0})
	queue({rm.r.text.new},{{"Not much to see here, huh?"}},{wait = -1})
end

local function example_1_alternative() -- An alternative option for queueing
	queue({rm.r.bkg.enter},{{bkg_ex}},{wait = 0.0})
	queue({rm.r.text.new},{{"So this is it..."}},{wait = 2.0})
	queue({rm.r.text.new},{{"Not much to see here, huh?"}},{wait = -1})
end

local M = { load = load, unload = unload, update = update, advance = advance, camera = camera }
return M