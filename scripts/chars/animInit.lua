
--[[
	//// animInit.lua ////
	Multi-use module for common functions used when setting up animations and loading and drawing characters.
]]



--[[
	Initializes the quads for one standard, 1-high n-wide, spritesheet for an enemy character.
	Returns the table of quads. Note that this is not the same as the actually shown frames of the animation.
]]
function newQuads(image, width)
    local quads = {}
    for x = 0, image:getWidth() - width, width do
        table.insert(quads, love.graphics.newQuad(x, 0, width, image:getHeight(), image:getDimensions()))
    end
    return quads
end

--[[
	Comparator for anim_queue elements.
	Returns true if the new element began sooner, false if it began later.
	If they started at the same time, returns true if the new element is equal or higher priority.
	Returns false by default for safety as not to return nil.

	Currently using this one because it seems safer to guarantee player will get most relevant visual feedback.
	TODO: live test around this case
]]
local function higher_prio_anim(new_e, old_e)
	if new_e.start > old_e.start then
		return true
	elseif old_e.start > new_e.start then
		return false
	else
		if new_e.anim.priority >= old_e.anim.priority then
			return true
		end
	end
	return false -- as to never return nil
end

--[[
	Outdated comparator for anim_queue elements.
	Prioritizes a higher "priority" animation versus a more recent animation.
]]
local function higher_prio_anim_deprecated(new_e, old_e)
	if new_e.anim.priority > old_e.anim.priority then
		return true
	elseif new_e.anim.priority < old_e.anim.priority then
		return false
	else
		if new_e.start >= old_e.start then
			return true
		end
	end
	return false
end

--[[
	Returns a new table for the anim_queue.anims layer.
	Sorts the layer in place, shifting indices after inserting new_e.
]]
local function sort_anim_layer(layer, new_e)
	if #layer ~= 0 then
		if not higher_prio_anim(new_e,layer[#layer]) then
			layer[#layer + 1] = new_e -- Edge case if new_e is not bigger than anything.
		else
			for i = 1,#layer do
				if higher_prio_anim(new_e,layer[i]) then
					for j = #layer,i,-1 do
						layer[j+1] = layer[j]
					end
					layer[i] = new_e
					break -- Ends the loop after finding the first thing new_e is bigger than.
				end
			end
		end
	else
		layer[1] = new_e -- Edge case if layer is empty.
	end
	return layer
end

local M = {newQuads = newQuads, sort_anim_layer = sort_anim_layer, higher_prio_anim = higher_prio_anim }
return M
