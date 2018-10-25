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
local hit_queue = {}
local anim_queue_player = {}
local anim_queue_enemy = {}

local beat = 0.0 -- a global timer for the beat. use this for EVERYTHING. SERIOUSLY.
local fighting = false -- tells us if the fight has started yet.
local timer = 0.0 -- a timer that we reset as needed, to keep track of NON-FIGHTING parts of the UI and such (fades, showing pre-fight text, etc.)

local player = nil -- you! contains animations, sounds
local enemy = nil -- the baddie! contains animations, sounds. 

local dbg = 0

local function debug_load()
	-- Runs the setup to test a basic, preset run of the rhythm game
	rhythm = require("scripts/procgen/testRhythm")
	rhyhtm.music:play()
end

local function load() -- Call this function when you want to switch to this stage
	-- Reinitalize the GUI
	-- gui = require('scripts/gui/Gspot') TODO: replace with a function to clear the GUI
	-- gui_font = love.graphics.newFont(72)
	-- love.graphics.setFont(gui_font)
	-- love.graphics.setColor(255, 192, 0, 128) 

	debug_load()

	-- TODO: Add some ambient intro/outro sounds. 
	--		Ambient fades out and music starts when the player hits go

	-- TODO: Before we start the game we have to pull the rhythm.pattern table, 
	-- 		and figure out how the player and enemy sounds and animations will
	--		line up with the abstract patterns.

	beat = (rhythm.offset * bpm / 60) * -1 -- sets the beat timer to account for the offset
end

local function update(dt) 

	timer = timer + 1 * dt

	-- pre-fight UI to trigger scene

	if fighting then
		beat = beat + (60 * dt / bpm)
	end

	-- check rhythm.beats if we're on a new half-beat
		-- add any new primes to the hit_queue
		-- if there's no more beats coming up, end the fight.

	-- check for misses in the hit_queue
		-- play the corresponding miss sound
		-- add the corresponding miss animation to the anim_queue
		-- clear the element from the hit_queue

	-- figure out the anim_queue
		-- atm, see notes

end

local function draw()
	love.graphics.print(tostring(dbg))

	-- draw the background renderer

	-- draw rhythm game elements
		-- draw background objects or obstructions
		-- draw the enemy
		-- draw the midground objects or obstructions
		-- draw the player
		-- draw the foreground objects or obstructions

	-- draw the character renderer
	-- draw the text renderer
end

local function keypressed(key)
	-- check the hit queue for any keypressed patterns
		-- play the corresponding hit sound
		-- add the corresponding hit animation to the anim_queue
		-- clear the element from the hit_queue
	-- whiff otherwise, which will do something TBD.
end

local function keyreleased(key)
	-- check the hit queue for any keyreleased patterns
		-- play the corresponding hit sound
		-- add the corresponding hit animation to the anim_queue
		-- clear the element from the hit_queue
end

local M = { allows_pause = allows_pause, load = load, unload = unload, update = update, draw = draw, keypressed = keypressed, keyreleased = keyreleased }
return M