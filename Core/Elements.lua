local _, ns = ...

local CLIENT = ns.CLIENT
local EXCLUDE = ns.EXCLUDE

local DAMAGE_METER_WINDOW_COUNT = 5
local CHAT_FRAME_COUNT = 10
local CHAT_DOCK_NAME = "GeneralDockManager"

local function BuildDamageMeterNames()
    local names = { "DamageMeter" }
    for index = 1, DAMAGE_METER_WINDOW_COUNT do
        names[#names + 1] = "DamageMeterSessionWindow" .. index
    end
    return names
end

-- Each element group lists frames by their global name. The names in "names" exist in
-- both clients and "clientNames" adds the ones of a single client. A name that does not
-- exist in the running client is skipped, so a wrong or missing name is harmless.
-- A group without excludeKey always fades and cannot be kept visible.
-- The Forever names still need a check in game, for example with /fstack.
local ELEMENTS = {
    {
        excludeKey = EXCLUDE.ACTION_BARS,
        names = {
            "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight",
            "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7", "StanceBar", "PetActionBar",
        },
    },
    {
        excludeKey = EXCLUDE.MICRO_MENU,
        names = {
            "CharacterMicroButton", "ProfessionMicroButton", "PlayerSpellsMicroButton",
            "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton",
            "CollectionsMicroButton", "EJMicroButton", "StoreMicroButton", "MainMenuMicroButton",
            "MicroButtonAndBagsBar",
        },
        clientNames = {
            [CLIENT.RETAIL] = { "HousingMicroButton" },
            -- Forever draws a border and a background on the menu frame itself.
            [CLIENT.FOREVER] = {
                "SpellbookMicroButton", "TalentMicroButton", "LegacyMicroButton",
                "HelpMicroButton", "MicroMenu",
            },
        },
    },
    {
        excludeKey = EXCLUDE.BAGS,
        names = {
            "MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot",
            "CharacterBag2Slot", "CharacterBag3Slot", "BagsBar",
        },
    },
    {
        -- Only the cluster fades. The minimap inherits its alpha.
        excludeKey = EXCLUDE.MINIMAP,
        names = { "MinimapCluster" },
    },
    {
        excludeKey = EXCLUDE.BUFFS,
        names = { "BuffFrame", "DebuffFrame" },
    },
    {
        excludeKey = EXCLUDE.UNIT_FRAMES,
        names = { "PlayerFrame", "TargetFrame", "FocusFrame", "CompactPartyFrame" },
    },
    {
        excludeKey = EXCLUDE.OBJECTIVES,
        names = { "ObjectiveTrackerFrame" },
    },
    {
        excludeKey = EXCLUDE.REP_BAR,
        names = { "StatusTrackingBarManager" },
    },
    {
        names = { "ExpansionLandingPageMinimapButton", "GarrisonLandingPageMinimapButton" },
    },
    {
        excludeKey = EXCLUDE.CHAT,
        names = { "QuickJoinToastButton" },
    },
    {
        excludeKey = EXCLUDE.DAMAGE_METER,
        names = BuildDamageMeterNames(),
    },
}

local function AddExistingFrames(frames, names)
    for _, name in ipairs(names or {}) do
        local frame = _G[name]
        if frame then
            frames[#frames + 1] = frame
        end
    end
end

local Elements = {}

-- Returns the groups with the frames that exist right now. Some frames are created late,
-- so the list is built again on every call.
function Elements.GetGroups()
    local groups = {}
    for _, element in ipairs(ELEMENTS) do
        local frames = {}
        AddExistingFrames(frames, element.names)
        AddExistingFrames(frames, element.clientNames and element.clientNames[ns.Client.current])
        groups[#groups + 1] = { excludeKey = element.excludeKey, frames = frames }
    end
    return groups
end

function Elements.GetChatFrames()
    local frames = {}
    for index = 1, CHAT_FRAME_COUNT do
        local chatFrame = _G["ChatFrame" .. index]
        if chatFrame and chatFrame:IsShown() then
            frames[#frames + 1] = chatFrame
            -- Forever shows the input box on its own, so it needs its own fade.
            local editBox = ns.Client.current == CLIENT.FOREVER and _G["ChatFrame" .. index .. "EditBox"]
            if editBox then
                frames[#frames + 1] = editBox
            end
        end
    end
    local dock = _G[CHAT_DOCK_NAME]
    if dock then
        frames[#frames + 1] = dock
    end
    return frames
end

ns.Elements = Elements
