local addonName, ns = ...

local EVENT_ADDON_LOADED = "ADDON_LOADED"
local EVENT_LOGIN = "PLAYER_LOGIN"

local eventFrame = CreateFrame("Frame")

-- The saved variables exist when the addon is loaded. The database is therefore ready
-- before the HUDFader file gets its first game event.
local function OnAddonLoaded()
    if not ns.Client.IsSupported() then
        return
    end
    ns.Database.Init()
    ns.Commands.Register()
    ns.MinimapButton.Create()
end

-- The chat is not ready while the addon loads, so the hint waits for the login.
local function OnLogin()
    if not ns.Client.IsSupported() then
        ns.Chat.Print(ns.TEXT.UNSUPPORTED_CLIENT)
    end
end

local function OnEvent(_, event, loadedAddon)
    if event == EVENT_ADDON_LOADED then
        if loadedAddon == addonName then
            OnAddonLoaded()
        end
    else
        OnLogin()
    end
end

eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:RegisterEvent(EVENT_ADDON_LOADED)
eventFrame:RegisterEvent(EVENT_LOGIN)
