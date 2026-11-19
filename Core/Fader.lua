local _, ns = ...

-- Remembers the alpha a frame had before this addon changed it.
-- A frame is only restored when it is in this table, so foreign alpha values stay untouched.
local originalAlpha = {}

local function Fade(frame, alpha)
    if originalAlpha[frame] == nil then
        originalAlpha[frame] = frame:GetAlpha()
    end
    frame:SetAlpha(alpha)
end

local function Restore(frame)
    local original = originalAlpha[frame]
    if original ~= nil then
        frame:SetAlpha(original)
        originalAlpha[frame] = nil
    end
end

-- Returns the alpha of the active mode, or nil when nothing should be faded.
local function GetTargetAlpha()
    local mode = ns.Modes.GetActive()
    if not mode then
        return nil
    end
    local settings = ns.Database.GetModeSettings(mode.key)
    if not settings.enabled then
        return nil
    end
    return settings.alpha
end

local Fader = {}

function Fader.Apply()
    local targetAlpha = GetTargetAlpha()
    for _, frame in ipairs(ns.Elements.GetFrames()) do
        if targetAlpha then
            Fade(frame, targetAlpha)
        else
            Restore(frame)
        end
    end
end

ns.Fader = Fader
