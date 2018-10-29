local music = love.audio.newSource("sound/sapporo/umbrella.mp3","stream")
local bpm = 85 -- ask Aidan, this is a tap guess

local timesig = 4 
-- how many beats in a bar. whether it's 4th or 8th or 5th notes doesn't matter, this is a calc against bpm

local offset = 0.0
-- time in seconds before the first beat should kick in

local pattern = {
	{	-- pattern[1], 		=	. , . , . , 1 , * , .
		key = "space", -- the key to press for this pattern's hit
		dir = "pressed",
		wait = 1.0, -- 1 beat of wait between prime and hit
		wait_buffer_early = 0.1, -- 1/10 of a beat of early buffer time
		wait_buffer_late = 0.2 -- 2/10 of a beat of late buffer time
		-- ALL THE ART AND FX are handled by stageRhythm and the character fighter files, NOT BY THE PROCGEN
	}, 	
	{	-- pattern[2], 		=	1 , . , . , . , * , .
		key = "space",
		dir = "released",
		wait = 4.0, -- 4 beats of wait
		wait_buffer_early = 0.2, -- 2/10 of a beat of early buffer time, to be a little nicer :)
		wait_buffer_late = 0.3, -- 3/10 of a beat of late buffer time
	},
	{	-- pattern[3], 		=	. , 3 , 2 , 1 , * * .
		key = "space",
		dir = "pressed",
		primes = 3, -- how many primes before the wait, default = 1
		countdown = 1.0, -- number of beats between each prime, default = 1.0. difficulty up if countdown =/= wait
		wait = 1.0,
		wait_buffer_early = 0.1, -- 2/10 of a beat of early buffer time, to be a little nicer :)
		wait_buffer_late = 0.2, -- 3/10 of a beat of late buffer time
		extra_hits = { 1.0, 1.0 } -- default is an empty array of extra hits, here: two extra hits, each one beat later. Uses the same early/late buffers
	}
}

local beats = {
	{}, 							-- 1
	{}, 							-- and
	{}, 							-- 2
	{}, 							-- and
	{}, 							-- 3
	{}, 							-- and
	{ primes = { 1 } }, 			-- 4		Prime for pattern 1
	{}, 							-- and, equals one full bar (don't have hits in the first bar)
	{}, -- bar 2 starts
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{}, -- bar 3 starts
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{}, -- bar 4 starts
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{}, -- bar 5 starts
	{},
	{},
	{},
	{},
	{},
	{},
	{}
} 
-- see notes oct 24 2018
-- each rhythm index is a beat which has beat[sounds], beat[art], beat[action] 
	-- (beat[special] can be added later for hard-coded special effects)
-- references patterns in a pattern table contained within patternGen or the pre-set rhythm file or w/e

local M = { beats = beats, pattern = pattern, offset = offset, bpm = bpm, timesig = timesig, music = music }
return M