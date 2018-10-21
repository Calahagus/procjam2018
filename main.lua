-- Stages
-- TODO: consider moving these functions into 
stage_menu = require("scripts/stages/stageMenu")
stage_vn = require("scripts/stages/stageVN")
stage_rhythm = require("scripts/stages/stageRhythm")

-- universal_calls = { allows_pause, load, update, draw }
-- TODO: write a test script that verifies that every stage has all universal calls

-- Renderers
-- gui = require('scripts/gui/Gspot')

stage = stage_menu
pause = require("scripts/gui/renderPause")

function love.load()
	stage_menu.load()
end

function love.update(dt)
	if not (pause.state and stage.allows_pause) then
		stage.update(dt)
	end
	pause.update(dt)
end

function love.keypressed(key)
	if key == 'escape' and stage.allows_pause then
		pause.target = not pause.target
	end
end

function love.draw()
	stage.draw()
	pause.draw()
end

function load_stage(target_stage)
	paused = false
	stage = target_stage
	stage.load()
end