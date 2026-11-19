local _, ns = ...

local DEFAULTS = ns.DEFAULTS
local SETTING = ns.SETTING

local MODE_DEFAULTS = {
    [SETTING.ENABLED] = DEFAULTS.ENABLED,
    [SETTING.ALPHA] = DEFAULTS.ALPHA_PERCENT,
    [SETTING.MOVE_DELAY] = DEFAULTS.MOVE_DELAY,
    [SETTING.IDLE_DELAY] = DEFAULTS.IDLE_DELAY,
    [SETTING.CHAT_DELAY] = DEFAULTS.CHAT_DELAY,
}

local db

local function SetDefault(target, key, value)
    if target[key] == nil then
        target[key] = value
    end
end

local function EnsureModeSettings(modeKey)
    local settings = db.fade[modeKey] or {}
    for setting, value in pairs(MODE_DEFAULTS) do
        SetDefault(settings, setting, value)
    end
    settings.exclude = settings.exclude or {}
    for _, excludeKey in ipairs(ns.EXCLUDE_ORDER) do
        SetDefault(settings.exclude, excludeKey, false)
    end
    db.fade[modeKey] = settings
end

local Database = {}

-- Only modes of the current client get settings. Saved variables are stored per
-- client folder anyway, so Retail and Forever never share them.
function Database.Init()
    InterfaceAutoFadeDB = InterfaceAutoFadeDB or {}
    db = InterfaceAutoFadeDB
    db.fade = db.fade or {}
    SetDefault(db, "minimapAngle", DEFAULTS.MINIMAP_ANGLE)
    for _, mode in ipairs(ns.Modes.GetAvailable()) do
        EnsureModeSettings(mode.key)
    end
end

function Database.GetModeSetting(modeKey, setting)
    return db.fade[modeKey][setting]
end

function Database.SetModeSetting(modeKey, setting, value)
    db.fade[modeKey][setting] = value
end

function Database.IsExcluded(modeKey, excludeKey)
    return db.fade[modeKey].exclude[excludeKey]
end

function Database.SetExcluded(modeKey, excludeKey, excluded)
    db.fade[modeKey].exclude[excludeKey] = excluded
end

function Database.GetMinimapAngle()
    return db.minimapAngle
end

function Database.SetMinimapAngle(angle)
    db.minimapAngle = angle
end

ns.Database = Database
