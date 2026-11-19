local _, ns = ...

local ALPHA = ns.ALPHA

-- Modes start disabled, so installing the addon does not change the interface by surprise.
local DEFAULT_ENABLED = false
local DEFAULT_ALPHA = ALPHA.DEFAULT_FADED

local db

local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function EnsureModeSettings(modeKey)
    local settings = db.modes[modeKey] or {}
    if settings.enabled == nil then
        settings.enabled = DEFAULT_ENABLED
    end
    if settings.alpha == nil then
        settings.alpha = DEFAULT_ALPHA
    end
    db.modes[modeKey] = settings
end

local Database = {}

-- Only modes of the current client get settings. Saved variables are stored per
-- client folder anyway, so Retail and Forever never share them.
function Database.Init()
    InterfaceAutoFadeDB = InterfaceAutoFadeDB or {}
    db = InterfaceAutoFadeDB
    db.modes = db.modes or {}
    for _, mode in ipairs(ns.Modes.GetAvailable()) do
        EnsureModeSettings(mode.key)
    end
end

function Database.GetModeSettings(modeKey)
    return db.modes[modeKey]
end

function Database.SetModeEnabled(modeKey, enabled)
    db.modes[modeKey].enabled = enabled
end

function Database.SetModeAlpha(modeKey, alpha)
    db.modes[modeKey].alpha = Clamp(alpha, ALPHA.MIN, ALPHA.MAX)
end

ns.Database = Database
