local busy

local target_text
local current_text

local function load() 
	-- Initialize the scene
	busy = false
end

local function update(dt) 
	print("Junk")
end

local function draw() 
	print("Junk")
end

-- hurry() tells the renderer to skip doing any sort of fancy crap, and go right to an unbusy state.
local function hurry()
	print("Junk")
end

-- Renderer specific functions
local function new(text, speed, size)

end

local function new_line(text, speed)

end

local function hide(speed)

end

local M = { busy = busy, load = load, update = update, draw = draw }
return M