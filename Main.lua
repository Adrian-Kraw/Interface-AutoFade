local _, ns = ...

local EVENT_LOGIN = "PLAYER_LOGIN"

local loginFrame = CreateFrame("Frame")

local function Start()
    if not ns.Client.IsSupported() then
        ns.Chat.Print(ns.TEXT.UNSUPPORTED_CLIENT)
        return
    end
    ns.Database.Init()
    ns.Commands.Register()
    ns.MinimapButton.Create()
    -- The game events come last, so no handler runs before the database exists.
    ns.Events.Register()
    ns.Fader.Apply()
end

loginFrame:SetScript("OnEvent", Start)
loginFrame:RegisterEvent(EVENT_LOGIN)
