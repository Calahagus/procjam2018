paused = false

stage_menu = require("scripts/stages/stageMenu")
stage_vn = require("scripts/stages/stageVN")
stage_rhythm = require("scripts/stages/stageRhythm")
stage = nil

function love.load()
	load_stage(stage_rhythm)
end

function love.update(dt)
	if not (paused and stage.allows_pause) then
		stage.update(dt)
	end
end

function love.draw()
	stage.draw()

	if paused then
		love.graphics.print("PAUSED",100,24)
		-- TODO: make this better
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
	stage.keypressed(key)
end

function love.keyreleased(key)
	-- if not fading out
	stage.keyreleased(key)
end

function load_stage(target_stage)
	-- TODO: add a fading-out function
	-- TODO: add a pre-loader (hard!)
	target_stage.load()
	stage = target_stage
	love.audio.stop()
	pause_clear()
end

function pause_clear()
	pause_state = false
	pause_target = false
	pause_fade = 0
end

