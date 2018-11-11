local bkg = require("scripts/renderers/renderBkg")
local chars = require("scripts/renderers/renderChar")
local text = require("scripts/renderers/renderText")

local allows_pause = true

-- ATM, I commented out the Gspot fixes because I'm not sure they're necessary. 
-- We only really need the GUI for the advancement notif, and that's just "press spacebar or click below a certain y"
-- I'm saying I can implement that myself without the need for scary modules with classes and bullshit.

-- local gui = require('scripts/libraries/Gspot')
-- -- Fixes that need to be called every time we instantiate Gspot for mouse changes in 0.10.
-- love.mousepressed = function(x, y, button)
-- 	gui:mousepress(x, y, button) -- pretty sure you want to register mouse events
-- end
-- love.mousereleased = function(x, y, button)
-- 	gui:mouserelease(x, y, button)
-- end

local beat = 0.0 -- A global timer for the beat. We try to use this and only this for every check relevant to the game.
local fighting = false
local fight_over = false
local timer = 0.0
local rhythm
local nextbeat = 1
local pattern
local hit_queue = {}
local anim_queue = { player = {}, enemy = {} }
local player = nil -- you! This and the relevant enemy var below is a link to the player module with animations, sounds, and story variables.
local enemy = nil -- the baddie!

local fader
local ambient

local dbg_counter = 0
local dbg = false

local function debug_load()
	dbg = true
	rhythm = require("scripts/procgen/testRhythm")	-- Runs the setup to test a basic, preset run of the rhythm game
	pattern = rhythm.pattern
	ambient.source = love.audio.newSource("sound/ambient/windy-forest-01.mp3","stream") -- this sucks but eh. its debug_load()
	--fader.img = 
	-- TODO: setup the from-black fader and have it tween too. You have another TODO down at the bottom of draw() to do this, so double do it.
end

local function load()
	fader = { fadeRatio = 1.0, img = nil }
	ambient = { fadeRatio = 0.5, timer = 0.0, source = nil }

	debug_load()

	if not dbg then
		pattern = rhythm.pattern
		for p = 1,#pattern do
			-- TODO: flesh out the pattern animations and sounds from the enemy and player files
			-- Add "anims" table to e.g. pattern[p].anim.hold.player
			-- Add love.sound.newSource to e.g. pattern[p].sound.attack
		end
	end

	beat = (rhythm.offset * rhythm.bpm / 60) * -1 -- Sets the beat timer to account for the offset
	ambient.source:play() -- TODO: figure out why this isn't playing from the start :(. Also this will break if we don't call debug_load() atm
end

local function start_fight()
	fighting = true
	rhythm.music:play()
end

local function end_fight()
	fighting = false
	fight_over = true
	ambient.source:play()
end

local function queue_pattern_sound(hit,trigger) then -- Plays the respective sound for holds, primes, hits, etc., right away!
	if hit.pattern.sound[trigger] then
		hit.pattern.sound[trigger]:clone():play()
	end
end

local function queue_pattern_anim(hit,trigger,extra_time) then -- Adds the respective animation to anim_queue. By default, animates immediately, but 
	if hit.pattern.anim[trigger] then
		local queues = {"player","enemy"}
		for i = 1,#queues do
			local anim = hit.pattern.anim[trigger][queues[i]]
			local anim_start_time = beat -- By default, start right now
			if anim.start then
				anim_start_time = hit.time[anim.start] + (anim.start_offset / anim.fps / 60 * rhythm.bpm) -- Converts FPS in the animation to beats
			end
			local anim_finish_time = anim_start_time + (#anim.quads / anim.fps / 60 * rhythm.bpm) -- By default, plays to the end of the animation
			if anim.finish then
				anim_finish_time = hit.time[anim.finish] + (anim.finish_offset / anim.fps / 60 * rhythm.bpm)
			else if anim.finish_offset then -- Sometimes, e.g. for hits/misses, we want to make the animation stay longer but still remain relative to the input
				anim_finish_time = anim_finish_time + anim.finish_offset
			end
			anim_start_time = anim_start_time + extra_time
			anim_finish_time = anim_finish_time + extra_time
			local queue_element = { start = anim_start_time, finish = anim_finish_time, pattern = hit.pattern }
			table.insert(anim_queue[queues[i]],queue_element)
		end
	end
end

local function queue_pattern_assets(hit,trigger) -- Only call this if you want to animate and do sounds at the same time.
	queue_pattern_sound(hit,trigger)
	queue_pattern_anim(hit,trigger,0.0)
end

local function update(dt) 
	-- Global timer in seconds
	timer = timer + 1 * dt

	-- Fade ambience in when not fighting, fade it out when the fight begins
	if fighting then ambient.timer = ambient.timer + 1 * dt else ambient.timer = ambient.timer - 1 * dt end
	ambient.source:setVolume(math.min(1.0, ambient.timer * ambient.fadeRatio))

	-- Timer counted in beats, used for the fight section.
	if fighting then
		beat = beat + (rhythm.bpm / 60 * dt)
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
				if pat.extra_hits then
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
						queue_pattern_anim(extra_hit,"attack",0.0)
					end
				end

				queue_pattern_assets(hit,"hold")	-- Play hold sounds and queue animations
				for i = 1,hit.primes.total do 		-- Queue "prime" animations, with any countdowns
					queue_pattern_anim(hit,"prime",(i-1)*hit.primes.countdown)
				end
				queue_pattern_anim(hit,"attack",0.0)	-- Queue the "attack" animation. We pre-queue this to be precise and allow for lead-up frames.
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
			queue_pattern_sound(hit,"prime")
			hit.primes.left = hit.primes.left - 1	-- Handles ticking down for countdown-type primes. I.E. a "3 2 1 Go!" type pattern.
		end

		-- Check the hit_queue to see if we're newly passed an attack in this frame
		if beat > hit.time.wait and not hit.attacked then
			queue_pattern_sound(hit,"attack")
			hit.attacked = true
		end

		-- Deal with any missed beats (due to LACK of player input)
		if beat > hit.time.late then
			queue_pattern_assets(hit,"miss")
			-- DEFERRED: score-related stuff
			table.remove(hit_queue,i) -- Clear the element from hit_queue
		end
	end
end

local function draw()
	-- TODO: Draw the background renderer

	-- TODO: Draw rhythm game elements
		-- DEFERRED: Draw background objects or obstructions
		-- Draw the enemy by sorting out anim_queue
		-- DEFERRED: Draw the midground objects or obstructions
		-- Draw the player by sorting out anim_queue
		-- DEFERRED: Draw the foreground objects or obstructions

	-- TODO: Draw the character renderer
	-- TODO: Draw the text renderer, and a UI symbol for advancement
	if not fighting and not text.busy then
		love.graphics.print("<Press Space to Begin>") -- PLACEHOLDER: for advancement GUI on top of the text box.
		-- TODO: maybe make an "advancement renderer" b/c in theory every level will call this... just need to be able to tell it to be active or not
	end

	-- TODO: Draw the fading-in black backdrop
end

local function whiff(key,dir)
	-- PLACEHOLDER
	-- TODO: whiff sound effect
end

local function parse_hit_queue(key,dir)
	local connected = false
	for i = #hit_queue,1,-1 do
		local hit = hit_queue[i] -- ez reference
		if beat > hit.time.early then -- Only do something if you swing on time. Swinging too early means you'll whiff.
			connected = true -- Connect even if you press the WRONG button. Avoids whiffing.
			if key == hit.pattern.key and dir == hit.pattern.dir then
				queue_pattern_assets(hit,"hit")
				table.remove(hit_queue,i)	-- Clear the element from hit_queue
			else
				-- PLACEHOLDER: if you do the *wrong* action on a queued hit.
				-- TODO: determine what happens. Probably should vary depending on the hit.
			end	
		end
	end
	if not connected then
		dbg_counter = dbg_counter + 1
		whiff(key,dir)
	end
end

local function keypressed(key)
	if key == "space" then
		if fighting then -- DEFERRED: make this check to see if, for pattern in patterns, key == pattern.key. This is a de facto list of "active" keys
			parse_hit_queue(key,"pressed")	-- Condensed function so code isn't duplicated.
		elseif not text.busy then
			start_fight()
		end
	end
end

local function keyreleased(key)
	if key == "space" and fighting then
		parse_hit_queue(key,"released")
	end
end

local M = { allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw, keypressed = keypressed, keyreleased = keyreleased }
return M