-- Background files contain a bunch of preset information and are responsible for
-- initalizing background art. When and only when a character is needed, we call
-- require(scripts/bkgs/bkgEX), which returns a table of info and art to be
-- used in the VN stage.

-- Basically, this is a character but we wanna keep the files seperate for organization.
-- In the future I anticipate these things will have different calls made on them too,
-- so it's good to keep them structurally different.

-- Preset background information
local info = {}
info[name] = "Jane City, Doe Land"

-- Initalizes a table of the background art
local art = {}
art[trees] = love.graphics.newImage('art/bkgs/ex/trees.png') 
	-- TODO: set this up to load piece by piece with a loading screen to not grind the program to a halt
		-- This will probably require passing a folder to initalize to a function (e.g. load_images()) in the main folder,
		-- so it can interface with the game-managing love.update(dt) function.

local M = { info = info, art = art }
return M