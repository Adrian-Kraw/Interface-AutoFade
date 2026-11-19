local _, ns = ...

local DEFAULTS = ns.DEFAULTS
local SETTING = ns.SETTING

-- The HUDFader files read InterfaceAutoFadeDB.interfaceFade[dbKey] directly,
-- so the layout of this table must stay as it is.
local MODE_DEFAULTS = {
    [SETTING.ENABLED] = DEFAULTS.ENABLED,
    [SETTING.ALPHA] = DEFAULTS.ALPHA_PERCENT,
    [SETTING.MOVE_DELAY] = DEFAULTS.MOVE_DELAY,
    [SETTING.IDLE_DELAY] = DEFAULTS.IDLE_DELAY,
    [SETTING.CHAT_DELAY] = DEFAULTS.CHAT_DELAY,
    [SETTING.HOVER_REVEAL] = DEFAULTS.HOVER_REVEAL,
}

local db

local function SetDefault(target, key, value)
    if target[key] == nil then
        target[key] = value
    end
end

local function EnsureExcludeDefaults(settings, excludeKeys)
    for _, excludeKey in ipairs(excludeKeys) do
        SetDefault(settings.exclude, excludeKey, false)
    end
end

local function EnsureModeSettings(mode)
    local settings = db.interfaceFade[mode.dbKey] or {}
    for setting, value in pairs(MODE_DEFAULTS) do
        SetDefault(settings, setting, value)
    end
    settings.exclude = settings.exclude or {}
    EnsureExcludeDefaults(settings, ns.EXCLUDE_ORDER)
    EnsureExcludeDefaults(settings, mode.extraExcludes or {})
    db.interfaceFade[mode.dbKey] = settings
end

local Database = {}

-- Only modes of the current client get settings. Saved variables are stored per
-- client folder anyway, so Retail and Forever never share them.
function Database.Init()
    InterfaceAutoFadeDB = InterfaceAutoFadeDB or {}
    db = InterfaceAutoFadeDB
    db.interfaceFade = db.interfaceFade or {}
    SetDefault(db, "minimapAngle", DEFAULTS.MINIMAP_ANGLE)
    for _, mode in ipairs(ns.Modes.GetAvailable()) do
        EnsureModeSettings(mode)
    end
end

function Database.GetModeSetting(dbKey, setting)
    return db.interfaceFade[dbKey][setting]
end

function Database.SetModeSetting(dbKey, setting, value)
    db.interfaceFade[dbKey][setting] = value
end

function Database.IsExcluded(dbKey, excludeKey)
    return db.interfaceFade[dbKey].exclude[excludeKey]
end

function Database.SetExcluded(dbKey, excludeKey, excluded)
    db.interfaceFade[dbKey].exclude[excludeKey] = excluded
end

function Database.GetMinimapAngle()
    return db.minimapAngle
end

function Database.SetMinimapAngle(angle)
    db.minimapAngle = angle
end

ns.Database = Database
