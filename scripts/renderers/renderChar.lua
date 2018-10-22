local busy

local chars
-- example char in chars:
-- char_ex = {}
-- char_ex[x] = 400
-- char_ex[y] = 400
-- char_ex[target_x] = 600
-- char_ex[target_y] = 600
-- char_ex[active_img] = < an image within the art table >
-- char_ex[passive_img] = < an image within the art table >
-- char_ex[fade] = < % into or out of the scene, or between the active and passive images >
-- char_ex[info]
-- char_ex[art] = < the art table from the character >

local function load() 
	-- Initialize the scene
	busy = false
	chars = {}
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

-- Renderer-specific functions
local function enter(name, speed, x, y, info, art, image)

end

local function new_img(name, speed, image)

end

local function exit(name, speed)

end

local function move(name, speed, target_x, target_y)
	-- move() moves a character to a position relative to their past position

end

local function set_pos(name, speed, target_x, target_y)
	-- set_pos() moves a character to a global position

end


local M = { busy = busy, load = load, update = update, draw = draw }
return M