local _, ns = ...

local CLIENT = ns.CLIENT

-- Elements are listed by their global frame name. A name that does not exist in the
-- running client is skipped, so a wrong or missing name is harmless.
-- Do not list a frame together with its parent, because the alpha would stack.

-- Frames with the same name in Retail and Forever.
local SHARED_FRAMES = {
    "MainActionBar",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarRight",
    "MultiBarLeft",
    "MultiBar5",
    "MultiBar6",
    "MultiBar7",
    "BuffFrame",
    "PlayerFrame",
    "ObjectiveTrackerFrame",
    "StatusTrackingBarManager",
}

-- Frames whose names differ per client. The Forever names come from other Forever
-- addons and still need a check in game, for example with /fstack.
local CLIENT_FRAMES = {
    [CLIENT.RETAIL] = {
        "CharacterMicroButton",
        "ProfessionMicroButton",
        "PlayerSpellsMicroButton",
        "AchievementMicroButton",
        "QuestLogMicroButton",
        "GuildMicroButton",
        "LFDMicroButton",
        "CollectionsMicroButton",
        "EJMicroButton",
        "StoreMicroButton",
        "MainMenuMicroButton",
        "HousingMicroButton",
    },
    [CLIENT.FOREVER] = {
        "CharacterMicroButton",
        "AchievementMicroButton",
        "QuestLogMicroButton",
        "GuildMicroButton",
        "LFDMicroButton",
        "CollectionsMicroButton",
        "EJMicroButton",
        "StoreMicroButton",
        "MainMenuMicroButton",
        "SpellbookMicroButton",
        "TalentMicroButton",
        "LegacyMicroButton",
        "HelpMicroButton",
    },
}

local function AddExistingFrames(frames, names)
    for _, name in ipairs(names) do
        local frame = _G[name]
        if frame then
            frames[#frames + 1] = frame
        end
    end
end

local Elements = {}

function Elements.GetFrames()
    local frames = {}
    AddExistingFrames(frames, SHARED_FRAMES)
    AddExistingFrames(frames, CLIENT_FRAMES[ns.Client.current] or {})
    return frames
end

ns.Elements = Elements
