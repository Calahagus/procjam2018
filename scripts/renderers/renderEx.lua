local busy = false
-- 'busy' is the variable that a stage can access to check whether the renderer is up to anything,
-- e.g. if characters are moving, text is scrolling in, etc.

local function load() 
	print("Junk")
end

local function update() 
	print("Junk")
end

local function draw() 
	print("Junk")
end

-- Functions to change stuff in the renderer

-- hurry() tells the renderer to skip doing any sort of fancy crap, and go right to an unbusy state.
local function hurry()
	print("Junk")
end

local M = { busy = busy, load = load, update = update, draw = draw }
return M