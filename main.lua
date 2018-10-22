pause_fade = 0
pause_target = false
pause_state = false

pause_fadescale = 200
pause_fademax = 100
pause_fademin = 0

stage_menu = require("scripts/stages/stageMenu")
stage_vn = require("scripts/stages/stageVN")
stage_rhythm = require("scripts/stages/stageRhythm")
stage = nil

function love.load()
	load_stage(stage_menu)
end

function love.update(dt)
	if not (pause_state and stage.allows_pause) then
		stage.update(dt)
	end

	if (pause_target and pause_fade < pause_fademax) then
		pause_fade = pause_fade + pause_fadescale * dt
	elseif not pause_target and pause_fade > pause_fademin then
		pause_fade = pause_fade - pause_fadescale * dt
	end
	pause_fade = math.min(pause_fade, pause_fademax)
	pause_fade = math.max(pause_fade, pause_fademin)
	if pause_fade > pause_fademin then 
		pause_state = true 
	else 
		pause_state = false 
	end
end

function love.draw()
	stage.draw()

	if pause_state then
		love.graphics.print("PAUSED",100,24)
		-- TODO: make this better 
	end
	love.graphics.print(tostring(pause_target),0,0)
	love.graphics.print(tostring(pause_fade),0,72)
end

function love.keypressed(key)
	if key == 'escape' and stage.allows_pause then
		pause_target = not pause_target
	end
end

function load_stage(target_stage)
	-- TODO: add a fading-out function
	-- TODO: add a pre-loader (hard!)
	target_stage.load()
	stage = target_stage
	pause_clear()
end

function pause_clear()
	pause_state = false
	pause_target = false
	pause_fade = 0
end

