
local animinit = require("scripts/chars/animInit")

-- Immutable character information
local info = {
	name = "D. McBg"
}

-- Initalizes a table of the character art for the VN stage
local art = {
	blink = {
		spritesheet = love.graphics.newImage("/art/vn/enemydbg/enemydbg_blink.png"),
		x = 0,
		y = 0,
		width = 96,
		quads = nil, 
		frames = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2,1,1,1,1,1,1,}, -- The quads to use for each frame. Allows for easy and inexpensive reuse of frames, and testing of delays
		-- TIME INFORMATION
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
	cut_prime = {
		id = "cut_prime",
		spritesheet = love.graphics.newImage("/art/fight/enemydbg/enemydbg_anim_cut_prime.png"),
		x = 0,
		y = 0,
		width = 128,
		quads = nil, 
		frames = {1,1,3,3,3,4,4,4},
		fps = 30,
		start = "began",
		start_offset = 0,
		finish = nil,
		finish_offset = 0,
		loop = false,
		priority = 3,
		layer = 1,
	},
	cut_hold = {
		id = "cut_hold",
		spritesheet = love.graphics.newImage("/art/fight/enemydbg/enemydbg_anim_cut_hold.png"),
		x = 0,
		y = 0,
		width = 128,
		quads = nil, 
		frames = {1},
		fps = 30,
		start = "began",
		start_offset = 0,
		finish = "late",
		finish_offset = 0,
		loop = true,
		priority = 2,
		layer = 1,
	},
	cut_hit = {
		id = "cut_hit",
		spritesheet = love.graphics.newImage("/art/fight/enemydbg/enemydbg_anim_cut_hit.png"),
		x = 0,
		y = 0,
		width = 128,
		quads = nil, 
		frames = {1,1,1,2,2,3,3,3,3,3,3,3,3,3,4,5,6,7,7,7,7,7,7},
		fps = 30,
		loop = false,
		priority = 3,
		layer = 1,
	},
	cut_miss = {
		id = "cut_miss",
		spritesheet = love.graphics.newImage("/art/fight/enemydbg/enemydbg_anim_cut_miss.png"),
		x = 0,
		y = 0,
		width = 128,
		quads = nil, 
		frames = {1,2,2,3,3,3,4,4,4},
		fps = 30,
		loop = false,
		priority = 3,
		layer = 1,
	},
}

for k, v in pairs(anim) do
	v.spritesheet:setFilter("nearest","nearest")
  	v.quads = animinit.newQuads(v.spritesheet,v.width)
end

local M = { info = info, art = art, anim = anim, load = load }
return M