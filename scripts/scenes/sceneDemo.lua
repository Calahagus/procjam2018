
local rm = require("scripts/renderers/_renderManager")

-- local char_ex = require("scripts/chars/charEX")
-- local bkg_ex = love.graphics.newImage("art/bkgs/ex.png")

local char_enemy = require("scripts/chars/charDBG")
local char_player = require("scripts/chars/playerDBG")

local background = love.graphics.newImage("art/bkgs/blank_background_1.png")
local foreground = love.graphics.newImage("art/bkgs/foreground_testing_2.png")

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

local function cam_player()
	queue({rm.cam.move},{{0,0,3.0}},{wait = 0.5})
end

local function cam_enemy()
	queue({rm.cam.move},{{384,0,3.0}},{wait = 0.5})
end

local function cam_fight()
	queue({rm.cam.move},{{192,0,3.0}},{wait = 0.0})
end

local function load() 
	queue({rm.r.bkg.set},{{background,4}},{wait = 0.0})
	queue({rm.r.char.enter},{{"sam",char_enemy,1000,64,"blink",-1}},{wait = 0.0})
	queue({rm.r.char.enter},{{"player",char_player,0,64,"idle",-1}},{wait = 4.0})
	queue({rm.r.fade.fade},{{-1,0.5}},{wait = 2.0})
	queue({rm.r.text.new},{{"Testing testing."}},{wait = -1})

	cam_enemy()
	queue({rm.r.text.new},{{"3"}},{wait = -1})

	cam_player()
	queue({rm.r.text.new},{{"2"}},{wait = -1})

	cam_enemy()
	queue({rm.r.text.new},{{"1"}},{wait = -1})

	cam_player()
	queue({rm.r.text.new},{{"let's jam *trumpets*"}},{wait = -1})

	queue({rm.r.text.hide},{{}},{wait = 0.0})
	cam_fight()
	queue({rm.r.char.move,rm.r.char.move},{{"sam",2000,64},{"player",-1000,64}},{wait = 2.0})
	-- queue({rm.r.char.exit},{{"sam"}},{wait = 0.0})
	queue({start_rhythm_fight},{{}},{wait = -1})

	advance()
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

local M = { load = load, update = update, advance = advance }
return M