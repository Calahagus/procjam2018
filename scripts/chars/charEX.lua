-- Character files contain a bunch of preset information and are responsible for
-- initalizing character art. When and only when a character is needed, we call
-- require(scripts/chars/charEX), which returns a table of info and art to be
-- used in a stage.

-- TODO: figure out how to make sure to handle garbage collection,
-- at least of the art. It's possible we want to hold onto and
-- modify character info and history w/r/t interactions with the player.

-- Per this: https://love2d.org/forums/viewtopic.php?t=82969
-- Can collect garbage by assigning nil to the char_art table,
-- while holding onto the info table.

-- Preset character information
local info = {}
info[name] = "Jane Doe"

-- Initalizes a table of the character art
local art = {}
art[happy] = love.graphics.newImage('art/char/ex/happy.png') 
	-- TODO: set this up to load piece by piece with a loading screen to not grind the program to a halt
		-- This will probably require passing a folder to initalize to a function (e.g. load_images()) in the main folder,
		-- so it can interface with the game-managing love.update(dt) function.

local M = { info = info, art = art }
return M