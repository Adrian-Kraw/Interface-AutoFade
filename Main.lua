local _, ns = ...

local EVENT_LOGIN = "PLAYER_LOGIN"
local EVENT_ENTERING_WORLD = "PLAYER_ENTERING_WORLD"
local EVENT_RESTING = "PLAYER_UPDATE_RESTING"

local eventFrame = CreateFrame("Frame")

local function Start()
    if not ns.Client.IsSupported() then
        ns.Chat.Print(ns.TEXT.UNSUPPORTED_CLIENT)
        return
    end
    ns.Database.Init()
    ns.Commands.Register()
    -- Zone changes and instance changes both end in a loading screen.
    eventFrame:RegisterEvent(EVENT_ENTERING_WORLD)
    eventFrame:RegisterEvent(EVENT_RESTING)
    ns.Fader.Apply()
end

local function OnEvent(_, event)
    if event == EVENT_LOGIN then
        Start()
    else
        ns.Fader.Apply()
    end
end

eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:RegisterEvent(EVENT_LOGIN)
