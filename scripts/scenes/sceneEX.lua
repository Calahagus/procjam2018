local bkg = require("scripts/renderers/renderBkg")
local chars = require("scripts/renderers/renderChar")
local text = require("scripts/renderers/renderText")

-- require gui, for choice options?

local char_ex = require("scripts/chars/charEX")
local bkg_ex = love.graphics.newImage("art/bkgs/ex.png")

local busy = false
local action_queue = {} -- cues up groups of actions for a renderer.
local aq_first = 0
local aq_last = -1
local next_call -- this variable cues up what the next scene call will be

local next_scene = "" -- tells the stage what the next scene will be. To go to a new stage, use load_stage(stage_rhythm)

local function load() 
	-- fade in, and do all the needed set-up for the scene
	-- cue up the next call
end

local function unload() 
	-- fade out
	-- call unload on the renderers to tidy up
	-- the function THAT CALLS UNLOAD will tell stageVN what the next scene needs to be
end

local function update(dt)
	-- if none of the renderers are busy:
		-- check if there's anything in the action_queue.
		-- if there is, make me busy and make the renderers do stuff
		-- otherwise, i'm not busy
end

local function queue(actions)
	-- a list of calls for the renderers to the action_queue
end

local function advance()
	-- if i'm not busy, makes the next_call happen. 
	-- if i am busy (and i didn't just make a call happen), send a hurry() to all renderers
end

-- HERE, WRITE THE SCENE SPECIFIC COMMANDS
-- (maybe need some sort of cue-ing command for subsequent actions, but this could be done hastily with "while(renderer.busy)"" loops)
local function example_1()
	queue({bkg.enter(bkg_ex),text.new("So this is it...")})
	queue({text.new_line("Not much to see here, huh?")})
end

local M = { load = load, unload = unload, update = update, busy = busy, advance = advance, next_scene = next_scene }
return M