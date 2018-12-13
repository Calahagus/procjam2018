
--[[
	//// beatMath.lua ////
	Multi-use module for common functions used when converting between seconds, frames, and beats.
]]

-- Converts a duration of frames to a duration in beats.
-- Returns a float value
local function frames_to_beats(frame_duration, fps, bpm)
	return (frame_duration / fps / 60) * bpm -- converts frames to minutes, then times beats per min
end

-- Converts a duration of beats to a floored frame number.
-- Returns an integer value
local function beats_to_frames(beat_duration, fps, bpm)
	return math.floor(beat_duration * (fps / bpm * 60)) -- calculates frames per beat and multiplies by the duration of beats
end

-- Converts a duration of seconds to a floored frame number.
-- Returns an integer value
local function time_to_frames(second_duration, fps)
	return math.floor(fps * second_duration)
end

M = { frames_to_beats = frames_to_beats, beats_to_frames = beats_to_frames, time_to_frames = time_to_frames }
return M