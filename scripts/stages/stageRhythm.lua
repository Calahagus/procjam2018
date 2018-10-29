local bkg = require("scripts/renderers/renderBkg")
local chars = require("scripts/renderers/renderChar")
local text = require("scripts/renderers/renderText")

local allows_pause = true

local gui = require('scripts/libraries/Gspot')

-- Fixes that need to be called every time we instantiate Gspot for mouse changes in 0.10
love.mousepressed = function(x, y, button)
	gui:mousepress(x, y, button) -- pretty sure you want to register mouse events
end
love.mousereleased = function(x, y, button)
	gui:mouserelease(x, y, button)
end

local rhythm
local nextbeat = 1
local pattern
local hit_queue = {}
local anim_queue = { player = {}, enemy = {} }

local beat = 0.0 -- a global timer for the beat. use this for EVERYTHING. SERIOUSLY.
local fighting = false -- tells us if the fight has started yet.
local timer = 0.0

local player = nil -- you! contains animations, sounds
local enemy = nil -- the baddie! contains animations, sounds. 

-- Ambient sounds, black-screens, etc. for twining
local fader
local ambient

local dbg = false
local function debug_load()
	dbg = true 
	-- Runs the setup to test a basic, preset run of the rhythm game
	rhythm = require("scripts/procgen/testRhythm")
	pattern = rhythm.pattern

	-- TODO: add the pattern sounds and audio to play the debug game

	ambient.source = love.audio.newSource("sound/ambient/windy-forest-01.mp3","stream")
	--fader.img = 
end

local function load()
	-- Reinitalize the GUI
	-- gui = require('scripts/gui/Gspot') TODO: replace with a function to clear the GUI
	-- gui_font = love.graphics.newFont(72)
	-- love.graphics.setFont(gui_font)
	-- love.graphics.setColor(255, 192, 0, 128) 

	fader = { fadeRatio = 1.0, img = nil }
	ambient = { fadeRatio = 0.5, timer = 0.0, source = nil }

	debug_load()

	if not dbg then
		pattern = rhythm.pattern
		for p = 1,#pattern do
			-- TODO: flesh out the pattern from the enemy and player files
			-- TODO: add pattern[i].anim.hold(.player or .enemy), anim.prime, .anim.hit, .anim.miss, .sound.hold, .sound.prime, .sound.attack, .sound.hit, .sound.miss
			-- use strings to index the stuff you add to pattern, so we can dynamically access this
			-- e.g. pattern.anim["miss"]
		end
	end

	beat = (rhythm.offset * rhythm.bpm / 60) * -1 -- sets the beat timer to account for the offset
	ambient.source:play()
end

local function start_fight()
	fighting = true
	rhythm.music:play()
end

local function end_fight()
	fighting = false
	ambient.source:play()
end

local function queue_pattern_assets(trigger)
	-- Play the respective sound for holds, primes, hits, etc.
	if hit.pattern.sound[trigger] then
		hit.pattern.sound[trigger]:clone():play()
	end

	-- Add the respective animation to anim_queue
	if hit.pattern.anim[trigger] then
		-- TODO: implement anim_queue
	end
end

local function update(dt) 
	-- Global timer in seconds
	timer = timer + 1 * dt

	-- Fade ambience in when not fighting, fade it out when the fight begins
	if fighting then ambient.timer = ambient.timer + 1 * dt else ambient.timer = ambient.timer - 1 * dt end
	ambient.source:setVolume(math.min(1.0, ambient.timer * ambient.fadeRatio))

	-- Timer counted in beats, used for the fight section.
	if fighting then
		beat = beat + (60 * dt / rhythm.bpm)
	end

	-- Checks if we're onto a new beat yet, and deal with the primes
	if beat > (nextbeat - 1) * 0.5 then
		local thisbeat = rhythm.beats[nextbeat]
		if thisbeat.primes then
			for p = 1,#thisbeat.primes do
				local pat = pattern[thisbeat.primes[p]] -- ez reference

				-- Add new primes to the hit_queue
				local hit = { 
					pattern = pat, 
					time = { began = (nextbeat - 1) * 0.5 }, 
					primes = { left = pat.primes or 1, total = pat.primes or 1, countdown = pat.countdown or pat.wait } 
				}		
				hit.time.wait = hit.time.began + pat.wait
				hit.time.early = hit.time.wait - pat.wait_buffer_early
				hit.time.late = hit.time.wait + pat.wait_buffer_late
				hit.attacked = false
				table.insert(hit_queue, hit)

				-- Handle extra hits, and add then to the hit_queue
				local extra_time = 0.0
				for e = 1,#pat.extra_hits do
					extra_time = extra_time + pat.extra_hits[e]
					local extra_hit = hit
					extra_hit.time.wait = extra_hit.time.wait + extra_time
					extra_hit.time.early = extra_hit.time.early + extra_time
					extra_hit.time.late = extra_hit.time.late + extra_time
					extra_hit.primes.left = 0 -- Strip primes from the extra hit, to avoid playing sounds twice.
					extra_hit.primes.total = 0
					table.insert(hit_queue, extra_hit)
				end

				queue_pattern_assets("hold")	-- Play hold sounds and queue animations
			end
		end

		-- DEFERRED: Special effects on this beat

		nextbeat = nextbeat + 1 			-- Iterate for the next global beat...
		if not rhythm.beats[nextbeat] then 	-- ...and end the fight if there's nothing left!
			end_fight()
		end
	end

	-- Parse the hit_queue
	for i = #hit_queue,1,-1 do
		local hit = hit_queue[i] -- ez reference

		-- Check the hit_queue for new primes
		if beat > hit.time.wait - hit.pattern.wait - ((hit.primes.left - 1) * hit.primes.countdown) and hit.primes.left > 0 then
			queue_pattern_assets("prime")
			hit.primes.left = hit.primes.left - 1	-- Handles ticking down for countdown-type primes. I.E. a "3 2 1 Go!" type pattern.
		end

		-- Check the hit_queue to see if we're newly passed an attack in this frame
		if beat > hit.time.wait and not hit.attacked then
			queue_pattern_assets("attack") -- Attack should never queue animations, but this is handled by just NOT having anim["attack"]
			hit.attacked = true
		end

		-- Deal with any missed beats (due to LACK of player input)
		if beat > hit.late then
			queue_pattern_assets("miss")
			-- DEFERRED: score-related stuff
			table.remove(hit_queue,i) -- Clear the element from hit_queue
		end
	end
end

local function draw()

	-- Draw the background renderer

	-- Draw rhythm game elements
		-- DEFERRED: Draw background objects or obstructions
		-- Draw the enemy by sorting out anim_queue
		-- DEFERRED: Draw the midground objects or obstructions
		-- Draw the player by sorting out anim_queue
		-- DEFERRED: Draw the foreground objects or obstructions

	-- Draw the character renderer
	-- Draw the text renderer

	-- Draw the fading-in black backdrop

	if not fighting and not text.busy then
		love.graphics.print("<Press Space to Begin>") -- PLACEHOLDER: for advancement GUI on top of the text box.
	end
end

local function whiff(key,dir)
	-- PLACEHOLDER
	-- TODO: whiff sound effect
end

local function parse_hit_queue(key,dir)
	local connected = false
	for i = #hit_queue,1,-1 do
		local hit = hit_queue[i] -- ez reference
		if beat > hit.early then -- Only do something if you swing on time. Swinging too early means you'll whiff.
			connected = true -- Connect even if you press the WRONG button. Avoids whiffing.
			if key == hit.key and dir == hit.dir then
				queue_pattern_assets("hit")
				table.remove(hit_queue,i)	-- Clear the element from hit_queue
			else
				-- PLACEHOLDER: if you do the *wrong* action on a queued hit.
				-- TODO: determine what happens. Probably should vary depending on the hit.
			end	
		end
	end
	if not connected then
		whiff(key,dir)
	end
end

local function keypressed(key)
	if key == "space" then
		if not fighting and not text.busy then
			start_fight()
		end
	end
	if key == "space" and fighting then -- DEFERRED: make this check to see if, for pattern in patterns, key == pattern.key. This is a de facto list of "active" keys
		parse_hit_queue(key,"pressed")	-- Condensed function so code isn't duplicated.
	end 
end

local function keyreleased(key)
	if key == "space" and fighting then
		parse_hit_queue(key,"released")
	end
end

local M = { allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw, keypressed = keypressed, keyreleased = keyreleased }
return M