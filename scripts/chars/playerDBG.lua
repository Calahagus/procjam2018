
local animinit = require("scripts/chars/animInit")

-- Immutable character information
local info = {
	name = "P. Leigh-Ur"
}

-- Initalizes a table of the character art for the VN stage
local art = {
	idle = {
		spritesheet = love.graphics.newImage("/art/vn/playerdbg/playerdbg_anim_vn_idle.png"),
		x = 0,
		y = 0,
		width = 96,
		quads = nil, 
		frames = {1},
		fps = 30,
		loop = true,
		layer = 1,
	}	
}

for k, v in pairs(art) do
	v.spritesheet:setFilter("nearest","nearest")
  	v.quads = animinit.newQuads(v.spritesheet,v.width)
end

-- Initalizes a table of the character animation for the rhythm stage
-- DEMO1 TODO: add placeholder player anims
local anim = {
	idle = {
		id = "idle",
		spritesheet = love.graphics.newImage("/art/fight/enemydbg/enemydbg_anim_idle.png"),
		x = 0,
		y = 0,
		width = 128,
		quads = nil, 
		frames = {1}, -- The quads to use for each frame. Allows for easy and inexpensive reuse of frames, and testing of delays
		-- TIME INFORMATION
		fps = 30,
		start = nil, -- nil, "began", early", "offset", or "late". Used for aligning the animation to parts of the hit
		start_offset = 0, -- in # of frames
		finish = nil, -- nil, "began", early", "offset", or "late". Used for aligning the animation to parts of the hit
		finish_offset = 0,
		-- QUEUE HANDLING OPTIONS
		loop = true, -- If false, anim_queue stays on the last frame after one cycle until the anim_queue element ends.
		priority = 1, --
		layer = 1, -- Up to one animation of each layer will play
	},
}

for k, v in pairs(anim) do
	v.spritesheet:setFilter("nearest","nearest")
  	v.quads = animinit.newQuads(v.spritesheet,v.width)
end

local M = { info = info, art = art, anim = anim, load = load }
return M