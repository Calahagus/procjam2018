local x = 0

local function update() 
	x = x + 1
end

local function draw() 
	love.graphics.print(tostring(x))
end

local M = { update = update, draw = draw }
return M