local _, ns = ...

local ALPHA = ns.ALPHA
local EXCLUDE = ns.EXCLUDE

-- Mode key to the alpha that mode wants. The highest wish wins.
-- Without any wish everything is fully visible.
local modeAlphas = {}
local inCombat = false

local function GetHighestModeAlpha()
    local highest
    for _, alpha in pairs(modeAlphas) do
        if highest == nil or alpha > highest then
            highest = alpha
        end
    end
    return highest or ALPHA.FULL
end

local function IsExcluded(excludeKey)
    if not excludeKey then
        return false
    end
    for modeKey in pairs(modeAlphas) do
        if ns.Database.IsExcluded(modeKey, excludeKey) then
            return true
        end
    end
    return false
end

local function FadeFrames(frames, alpha)
    for _, frame in ipairs(frames) do
        ns.FadeEngine.FadeTo(frame, alpha)
    end
end

local function ShowMinimap()
    if Minimap then
        Minimap:SetAlpha(ALPHA.FULL)
    end
    ns.MinimapOverlays.Show()
end

local function ApplyMinimap(highestAlpha)
    if highestAlpha == ALPHA.HIDDEN and not IsExcluded(EXCLUDE.MINIMAP) then
        ns.MinimapOverlays.Hide()
    else
        ShowMinimap()
    end
end

local Fader = {}

function Fader.Apply()
    if inCombat then
        return
    end
    local highest = GetHighestModeAlpha()
    for _, group in ipairs(ns.Elements.GetGroups()) do
        FadeFrames(group.frames, IsExcluded(group.excludeKey) and ALPHA.FULL or highest)
    end
    FadeFrames(ns.Elements.GetChatFrames(), IsExcluded(EXCLUDE.CHAT) and ALPHA.FULL or highest)
    ApplyMinimap(highest)
end

-- Forgets all wishes and shows everything. Used when combat starts.
function Fader.ShowAll()
    wipe(modeAlphas)
    ShowMinimap()
    for _, group in ipairs(ns.Elements.GetGroups()) do
        FadeFrames(group.frames, ALPHA.FULL)
    end
    FadeFrames(ns.Elements.GetChatFrames(), ALPHA.FULL)
end

-- Shows the chat for a while when a message arrives.
function Fader.ShowChat()
    FadeFrames(ns.Elements.GetChatFrames(), ALPHA.FULL)
end

function Fader.ResetMinimap()
    ShowMinimap()
end

function Fader.SetModeAlpha(modeKey, alpha)
    modeAlphas[modeKey] = alpha
    Fader.Apply()
end

function Fader.ClearMode(modeKey)
    modeAlphas[modeKey] = nil
    Fader.Apply()
end

function Fader.SetInCombat(value)
    inCombat = value
end

function Fader.IsInCombat()
    return inCombat
end

ns.Fader = Fader
