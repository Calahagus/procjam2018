local fade = 0
local fadescale = 200
local fademax = 100
local fademin = 0
local target = false

local state

local function update(dt) 
	if (target and fade < fademax) then
		fade = fade + fadescale * dt
	elseif not target and fade > fademin then
		fade = fade - fadescale * dt
	end
	fade = math.min(fade, fademax)
	fade = math.max(fade, fademin)
	if fade > fademin then 
		state = true 
	else 
		state = false 
	end
end

local function draw() 
	if state then
		love.graphics.print("PAUSED",100,24)
		-- TODO: make this better 
	end
	love.graphics.print(tostring(target),0,0)
	love.graphics.print(tostring(fade),0,72)
end

local M = { update = update, draw = draw, state = state, target = target }
return M