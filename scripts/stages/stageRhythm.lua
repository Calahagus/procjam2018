
local tween = require("scripts/libraries/tween")
local rendermanager = require("scripts/renderers/_renderManager")

-- DEFERRED POST-DEMO1: clean this shit up
local adv = require("scripts/renderers/renderAdvance")
local bkg = require("scripts/renderers/renderBkg")
local chars = require("scripts/renderers/renderChar")
local fade = require("scripts/renderers/renderFade")
local text = require("scripts/renderers/renderText")

local animator = require("scripts/chars/animInit")
local beatmath = require("scripts/beatMath")

local scene
local allows_pause = true

-- ATM, I deleted the Gspot fixes because I'm not sure they're necessary. 
-- We only really need the GUI for the advancement notif, and that's just "press spacebar or click below a certain y"
-- I'm saying I can implement that myself without the need for scary modules with classes and bullshit.

local beat = 0.0 -- A global timer for the beat. We try to use this and only this for every check relevant to the game.
local starting = false
local fighting = false
local fight_over = false
local timer = 0.0
local rhythm
local nextbeat = 1

local music = {
	src = nil,
	tween = nil,
	vol = {val = 0.0}
}

local player = nil -- you! This and the relevant enemy var below is a link to the player module with animations, sounds, and story variables.
local enemy = nil -- the baddie!

local pattern
local hit_queue = {}
local anim_queue = { player = { meta = { last = {}, restart = {},}, anims = {},}, enemy = { meta = { last = {}, restart = {}, }, anims = {},},}

local holdlimit = 0.0
local holdstarted = 0.0
local cooldown = 0.0

local ambient

local dbg = false

--[[  ///////////////////////
      //  SETUP FUNCTIONS  //
      ///////////////////////  ]]

local function debug_load()
	dbg = true
	rhythm = require("scripts/procgen/testRhythm")	-- Runs the setup to test a basic, preset run of the rhythm game
	enemy = require("scripts/chars/charDBG")
	pattern = rhythm.pattern

	-- ambient.source = love.audio.newSource("sound/ambient/windy-forest-01.mp3","stream") 
	-- ambient.source:play() -- DEFERRED: better ambient, and figure out why this isn't playing from the start

	change_scene("sceneDemo",false)
end

local function queue_idle() 
	local enemyidle = { anim = enemy.anim.idle, start = 100*beatmath.frames_to_beats(#enemy.anim.idle.frames, enemy.anim.idle.fps, rhythm.bpm), finish = -1 }
	table.insert(anim_queue.enemy.anims, enemyidle)
	-- local playeridle = { anim = player.anim.idle, start = 100*beatmath.frames_to_beats(#player.anim.idle.frames, player.anim.idle.fps, rhythm.bpm), finish = -1 }
	-- table.insert(anim_queue.player.anims, playeridle)
end

local function load()
	-- Load stage-specific stuff
	ambient = { fadeRatio = 0.5, timer = 0.0, source = nil }
	debug_load()
	if not dbg then
		pattern = rhythm.pattern
		for p = 1,#pattern do
			-- DEFERRED POST-DEMO1: flesh out the pattern animations and sounds from the enemy and player files
		end
	end
	queue_idle()
end

local function start_fight()
	beat = (rhythm.offset * rhythm.bpm / 60) * -1 -- Sets the beat timer to account for the offset
	-- DEFERRED POST-DEMO1: modify all idles in the anim_queue so that animation doesn't jump on start
	fighting = true
	music.src = rhythm.music:clone()
	music.src:play()
	music.tween = tween.new(rhythm.timesig*60/rhythm.bpm/9999999,music.vol,{val = 0.1},"inExpo")
end

local function end_fight()
	fighting = false
	fight_over = true
	-- ambient.source:play()
	music.tween = tween.new(4*rhythm.timesig*60/rhythm.bpm,music.vol,{val = 0.0},"outQuad")
end

local function set_scene(new_scene)
	scene = new_scene
end

local function get_scene()
	return scene
end

--[[  ////////////////////////
      //  UPDATE FUNCTIONS  //
      ////////////////////////  ]]

local function queue_pattern_sound(hit,trigger) -- Plays the respective sound for holds, primes, hits, etc., right away!
	if hit.pattern.sound[trigger] then
		hit.pattern.sound[trigger]:clone():play()
	end
end

-- Adds the respective animation to anim_queue. By default, animates immediately.
local function queue_pattern_anim(hit,trigger,extra_time) 
	local extra_time = extra_time or 0.0
	-- DEFERRED POST-DEMO1: set this up to be more dynamic. Eventually want to be able to animate background/foreground/etc. independently. (e.g. NPCs react)
	local queues = {"player","enemy"} 
	for i = 1,#queues do
		if hit.pattern.anim[queues[i]][trigger] ~= nil then
			local anim = hit.pattern.anim[queues[i]][trigger]
			local anim_start_time = beat -- By default, start right now
			if anim.start then
				anim_start_time = hit.time[anim.start] + beatmath.frames_to_beats(anim.start_offset, anim.fps, rhythm.bpm)
			end
			local anim_finish_time = anim_start_time + beatmath.frames_to_beats(#anim.frames, anim.fps, rhythm.bpm) -- By default, plays to the end of the animation
			if anim.finish then
				anim_finish_time = hit.time[anim.finish] + beatmath.frames_to_beats(anim.finish_offset, anim.fps, rhythm.bpm)
			end
			anim_start_time = anim_start_time + extra_time
			anim_finish_time = anim_finish_time + extra_time
			local queue_element = { anim = anim, start = anim_start_time, finish = anim_finish_time, pattern = hit.pattern }
			table.insert(anim_queue[queues[i]].anims,queue_element)
		end
	end
end

-- Add an animation and play a sound at the same time.
local function queue_pattern_assets(hit,trigger)
	queue_pattern_sound(hit,trigger)
	queue_pattern_anim(hit,trigger,0.0)
end

local function queue_hits(thisbeat)
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
			for i = 1,hit.primes.total do 		-- Queue ALL "prime" animations, with any countdowns
				queue_pattern_anim(hit,"prime",(i-1)*hit.primes.countdown)
			end
			queue_pattern_anim(hit,"attack",0.0)	-- Queue the "attack" animation. We pre-queue this to be precise and allow for lead-up frames.
		end
	end
end

local function update(dt) 
	-- Global timer in seconds
	timer = timer + 1 * dt
	cooldown = math.max(0.0,cooldown-dt)
	
	--[[

	holdlimit = math.max(0.0,cooldown-dt)
	if holdlimit == 0.0 then -- AND keydown(space)
		keyreleased()
	end

	]]

	if music.tween then music.tween:update(dt) end
	if music.src then music.src:setVolume(music.vol.val) end
	-- DEFERRED POST-DEMO1: tweening for ambient

	-- We update beat every frame regardless of fighting, bc beat is used for animation. 
	beat = beat + (rhythm.bpm / 60 * dt)
	-- DEFERRED POST-DEMO1: Reset beat in a way that avoids animation skips

	-- Checks if we're onto a new beat yet, and deal with the primes
	if fighting then
		if beat > (nextbeat - 1) * 0.5 then
			local thisbeat = rhythm.beats[nextbeat]
			queue_hits(thisbeat)

			-- DEFERRED UNTIL FURTHER NOTICE: Special effects on this beat

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
end

--[[  //////////////////////
      //  DRAW FUNCTIONS  //
      //////////////////////  ]]

-- Cleans up any outdated anim_queue elements, sorts the queue layers, then draws each layer of the animation.
local function draw_anim_queue(subq,pos,cam,scale)
	-- Queue cleanup and layer sorting
	local layers = {}
	for i = #anim_queue[subq].anims,1,-1 do
		local e = anim_queue[subq].anims[i]
		-- Clear out any elements past their expiration date
		if e.finish <= beat and e.finish ~= -1 then
			table.remove(anim_queue[subq].anims,i)
		end
		-- Organize and sort each layer
		if layers[e.anim.layer] == nil then
			layers[e.anim.layer] = {}
		end
		layers[e.anim.layer] = animator.sort_anim_layer(layers[e.anim.layer],e)
	end
	-- Calculate the frame we need to be on and draw each layer
	for i = 1,#layers do
		local active = layers[i][1]
		
		local frame = 1
		if active.anim.loop then 
			frame = (beatmath.beats_to_frames(beat - active.start,active.anim.fps,rhythm.bpm) % #active.anim.frames) + 1
		else
			frame = math.min(#active.anim.frames, (beatmath.beats_to_frames(beat - active.start,active.anim.fps,rhythm.bpm))+1)
		end
		love.graphics.draw(active.anim.spritesheet,active.anim.quads[active.anim.frames[frame]],0+active.anim.x+(pos.x*scale)-cam.x,0+active.anim.y+(pos.y*scale)-cam.y,0,scale)
	end
	-- Copy the sorted layers out to the meta queue to check in the next frame
	anim_queue[subq].meta.last = layers
end

local function draw()
	local camera = rendermanager.cam.get_pos()
	bkg.draw(camera)
	-- DEFERRED POST-DEMO1 FOR UPDATE TO renderBkg: Draw background objects or obstructions
	draw_anim_queue("enemy",{x = 108,y = -10},camera,4)
	-- DEFERRED POST-DEMO1 FOR UPDATE TO renderBkg: Draw the midground objects or obstructions
	-- TODO FOR DEMO1 WITH PLACEHOLDER ART: draw_anim_queue("player")
	-- DEFERRED POST-DEMO1 FOR UPDATE TO renderBkg: Draw the foreground objects or obstructions
	chars.draw(camera)
	text.draw(camera)
	if not fighting and not rendermanager.get_busy() then adv.draw(camera) end
	fade.draw()
end

--[[  ///////////////////////
      //  INPUT FUNCTIONS  //
      /////////////////////// ]]

local function whiff(key,dir)
	-- TODO: Whiff sound effect
	-- TODO: Whiff animation
	if key == "space" and dir == "released" then
		cooldown = 0.2
	end
end

local function check_hit_queue(key,dir)
	local connected = false
	for i = #hit_queue,1,-1 do
		local hit = hit_queue[i]
		if beat > hit.time.early then -- Only do something if you swing on time. Swinging too early means you'll whiff.
			connected = true -- Connect even if you press the WRONG button. Avoids whiffing.
			if key == hit.pattern.key and dir == hit.pattern.dir then
				queue_pattern_assets(hit,"hit")
				table.remove(hit_queue, i)	-- Clear the element from hit_queue
			else
				-- DEFERRED POST-DEMO: Determine what happens gameplay-wise. Should vary depending on the hit. ATM, it's nothing.
			end	
		end
	end
	if not connected then
		whiff(key,dir)
	end
end

local function keypressed(key)
	if key == "space" then
		if fighting then -- DEFERRED: make this check to see if, for pattern in patterns, key == pattern.key. This is a de facto list of "active" keys
			holdstarted = love.timer.getTime()
			if cooldown == 0.0 then
				check_hit_queue(key,"pressed")	-- Condensed function so code isn't duplicated.
			end
		elseif scene then
			if not rendermanager.get_busy() then
				scene.advance()
			else
				rendermanager.hurry()
			end
		end
	end
end

local function keyreleased(key)
	if key == "space" and fighting then
		check_hit_queue(key,"released")
	end
end

local M = { set_scene = set_scene, get_scene = get_scene, allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw, keypressed = keypressed, keyreleased = keyreleased, start_fight = start_fight }
return M