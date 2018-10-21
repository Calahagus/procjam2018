local allows_pause = true

local gui = require('scripts/gui/Gspot')

local function load() -- Call this function when you want to switch to this stage
	print("Junk")
end

local function update(dt) 
	print("Junk")
end

local function draw() 
	print("Junk")
	-- Draw backgrounds, possibly in transition from a previous state
	-- Draw characters, possibly in transition from a previous state
	-- Render some text
end

local M = { allows_pause = allows_pause, load = load, update = update, draw = draw }
return M