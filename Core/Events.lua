local _, ns = ...

local PLAYER_UNIT = "player"

local EVENT = {
    ENTERING_WORLD = "PLAYER_ENTERING_WORLD",
    COMBAT_START = "PLAYER_REGEN_DISABLED",
    COMBAT_END = "PLAYER_REGEN_ENABLED",
    STARTED_MOVING = "PLAYER_STARTED_MOVING",
    STOPPED_MOVING = "PLAYER_STOPPED_MOVING",
    RESTING = "PLAYER_UPDATE_RESTING",
    ZONE_INDOORS = "ZONE_CHANGED_INDOORS",
    ZONE_NEW_AREA = "ZONE_CHANGED_NEW_AREA",
    FLAGS_CHANGED = "PLAYER_FLAGS_CHANGED",
}

local CHAT_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
    "CHAT_MSG_CHANNEL", "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
}

local isChatEvent = {}
for _, event in ipairs(CHAT_EVENTS) do
    isChatEvent[event] = true
end

local function ForEachController(methodName)
    for _, controller in ipairs(ns.ModeController.GetAll()) do
        controller[methodName]()
    end
end

local function OnEnteringWorld()
    ns.Fader.SetInCombat(false)
    -- Reset the minimap state first, otherwise the hooks would hide the overlays again.
    ns.Fader.ResetMinimap()
    ForEachController("OnEnteringWorld")
end

local function OnCombatStart()
    ns.Fader.SetInCombat(true)
    ForEachController("OnCombatStart")
    ns.Fader.ShowAll()
end

local function OnCombatEnd()
    ns.Fader.SetInCombat(false)
    ForEachController("OnCombatEnd")
end

local function OnZoneChanged()
    ForEachController("OnZoneChanged")
end

local HANDLERS = {
    [EVENT.ENTERING_WORLD] = OnEnteringWorld,
    [EVENT.COMBAT_START] = OnCombatStart,
    [EVENT.COMBAT_END] = OnCombatEnd,
    [EVENT.STARTED_MOVING] = function() ForEachController("OnStartedMoving") end,
    [EVENT.STOPPED_MOVING] = function() ForEachController("OnStoppedMoving") end,
    [EVENT.RESTING] = OnZoneChanged,
    [EVENT.ZONE_INDOORS] = OnZoneChanged,
    [EVENT.ZONE_NEW_AREA] = OnZoneChanged,
    [EVENT.FLAGS_CHANGED] = OnZoneChanged,
}

local function OnEvent(_, event)
    if isChatEvent[event] then
        ForEachController("OnChatEvent")
        return
    end
    HANDLERS[event]()
end

local Events = {}

function Events.Register()
    local frame = CreateFrame("Frame")
    for event in pairs(HANDLERS) do
        if event == EVENT.FLAGS_CHANGED then
            -- Only for the own character, otherwise flags of other players cancel the timers.
            frame:RegisterUnitEvent(event, PLAYER_UNIT)
        else
            frame:RegisterEvent(event)
        end
    end
    for _, event in ipairs(CHAT_EVENTS) do
        frame:RegisterEvent(event)
    end
    frame:SetScript("OnEvent", OnEvent)
end

ns.Events = Events
