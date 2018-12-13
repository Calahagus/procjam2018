
copy = require("scripts/libraries/copy")

-- POST-DEMO1 CODE TODO:
--[[
	-- Fix ALL modules to use a self return method rather than the current M = {...}; return M;
	-- Menu screen and choice GUI 
	-- Seriously update stageVN
	-- Implement a proper gameplay ( talk->fight->|| ) cycle
	-- Implement basic ProcGen for fights
	-- Improve the stageRhythm draw() function
	-- Improve character controls, whiffing, etc. (with gameplay changes based on playtest feedback)
	-- renderChar.say(), and other quality-of-life updates to renderers (e.g. implement tween) and scene-writing
	-- Research and test garbage collection
	-- Improve audio handling
	-- Improve pause screen
	-- Create proper character files as art is created and ready to rig
	-- Move animInit, beatMath, tween, and other helper libraries to main.lua exclusively
]] 

paused = false

stage_menu = require("scripts/stages/stageMenu")
stage_vn = require("scripts/stages/stageVN")
stage_rhythm = require("scripts/stages/stageRhythm")

local stage = nil

local queue_stage = nil
local queue_scene = nil

local rendermanager = require("scripts/renderers/_renderManager")

function pause_clear()
	pause_state = false
	pause_target = false
	pause_fade = 0
end

function love.load()
	rendermanager.load()
	stage = stage_rhythm -- DEBUG
	stage.load()
end

function love.update(dt)
	if not (paused and stage.allows_pause) then
		stage.update(dt)
		rendermanager.update(dt)
	end
	-- Handle changing stages and scenes
	if (queue_stage ~= nil or queue_scene ~= nil) and not rendermanager.r.fade.busy then
		love.audio.stop()
		pause_clear()
		if queue_stage ~= nil then
			stage = queue_stage
			queue_stage = nil
			stage.load()
		end
		if queue_scene ~= nil then
			stage.set_scene(queue_scene)
			queue_scene = nil
			stage.get_scene().load()
		end
	end
end

function love.draw()
	stage.draw()

	if paused then
		love.graphics.print("PAUSED",100,24)
		-- DEFERRED: make this better
	end
	--love.graphics.print(tostring(paused),0,72)
end

function love.keypressed(key)
	if key == 'escape' and stage.allows_pause then
		paused = not paused
		if paused then
			-- love.audio.pause()
			-- see https://www.love2d.org/wiki/Source:clone, need to have a sound manager or something :(
		end
	end
	-- if not fading out
	if not paused then
		stage.keypressed(key)
	end
end

function love.keyreleased(key)
	-- if not fading out
	if not paused then
		stage.keyreleased(key)
	end
end

function change_stage(new_stage,new_scene,fade)
	if not fade == false then rendermanager.r.fade.fade() end
	rendermanager.r.text.hide()
	queue_stage = require("scripts/stages/"..new_stage)
	if new_scene then queue_scene = require("scripts/scenes/"..new_scene) end
end

function change_scene(new_scene,fade)
	if not fade == false then rendermanager.r.fade.fade() end
	rendermanager.r.text.hide()
	queue_scene = require("scripts/scenes/"..new_scene)
end

function start_rhythm_fight()
	rendermanager.r.text.hide()
	if stage.start_fight then
		stage.start_fight()
	end
end

