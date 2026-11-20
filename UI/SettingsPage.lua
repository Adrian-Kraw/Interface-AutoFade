local _, ns = ...

local TEMPLATE = ns.TEMPLATE
local TEXT = ns.TEXT
local SETTING = ns.SETTING
local LIMITS = ns.LIMITS

local SLIDER_STEP = 1

local function FormatPercent(value)
    return string.format(TEXT.PERCENT_FORMAT, value)
end

local function FormatSeconds(value)
    return string.format(TEXT.SECONDS_FORMAT, value)
end

local function FormatMoveDelay(value)
    if value == 0 then
        return TEXT.INSTANT
    end
    return FormatSeconds(value)
end

-- The fade code lives in the HUDFader files. Their methods for the second and third mode
-- end with the suffix of the mode, for example SetEnabled2.
local function CallFader(methodName, mode, ...)
    local fader = ns.HUDFader
    fader[methodName .. mode.apiSuffix](fader, ...)
end

local function InsertSlider(modeNode, mode, slider)
    modeNode:Insert({
        template = TEMPLATE.SLIDER,
        label = slider.label,
        min = slider.limits.MIN,
        max = slider.limits.MAX,
        step = slider.limits.STEP or SLIDER_STEP,
        format = slider.format,
        getValue = function()
            return ns.Database.GetModeSetting(mode.dbKey, slider.setting)
        end,
        setValue = function(value)
            ns.Database.SetModeSetting(mode.dbKey, slider.setting, value)
            if slider.appliesAlpha then
                CallFader("ApplyAlpha", mode)
            end
        end,
    })
end

local function InsertExcludeToggle(modeNode, mode, excludeKey)
    modeNode:Insert({
        template = TEMPLATE.TOGGLE,
        name = TEXT.EXCLUDE_LABEL[excludeKey],
        getValue = function()
            return ns.Database.IsExcluded(mode.dbKey, excludeKey)
        end,
        setValue = function(excluded)
            ns.Database.SetExcluded(mode.dbKey, excludeKey, excluded)
            ns.HUDFader:Refresh()
        end,
    })
end

-- The hover option sits at the top of each mode. The fader reads the saved value directly,
-- so a refresh applies a change at once.
local function InsertHoverToggle(modeNode, mode)
    modeNode:Insert({
        template = TEMPLATE.TOGGLE,
        name = TEXT.TOGGLE_HOVER_REVEAL,
        getValue = function()
            return ns.Database.GetModeSetting(mode.dbKey, SETTING.HOVER_REVEAL)
        end,
        setValue = function(enabled)
            ns.Database.SetModeSetting(mode.dbKey, SETTING.HOVER_REVEAL, enabled)
            ns.HUDFader:Refresh()
        end,
    })
end

local function InsertMode(dataProvider, mode)
    local modeNode = dataProvider:Insert({
        template = TEMPLATE.HEADER,
        name = TEXT.MODE_LABEL[mode.key],
        getEnabled = function()
            return ns.Database.GetModeSetting(mode.dbKey, SETTING.ENABLED)
        end,
        setEnabled = function(enabled)
            CallFader("SetEnabled", mode, enabled)
        end,
    })
    modeNode:SetCollapsed(true)

    InsertHoverToggle(modeNode, mode)
    InsertSlider(modeNode, mode, {
        label = TEXT.SLIDER_TRANSPARENCY,
        setting = SETTING.ALPHA,
        limits = LIMITS.ALPHA,
        format = FormatPercent,
        appliesAlpha = true,
    })
    InsertSlider(modeNode, mode, {
        label = TEXT.SLIDER_MOVE_DELAY,
        setting = SETTING.MOVE_DELAY,
        limits = LIMITS.MOVE_DELAY,
        format = FormatMoveDelay,
    })
    InsertSlider(modeNode, mode, {
        label = TEXT.SLIDER_IDLE_DELAY,
        setting = SETTING.IDLE_DELAY,
        limits = LIMITS.IDLE_DELAY,
        format = FormatSeconds,
    })
    InsertSlider(modeNode, mode, {
        label = TEXT.SLIDER_CHAT_DELAY,
        setting = SETTING.CHAT_DELAY,
        limits = LIMITS.CHAT_DELAY,
        format = FormatSeconds,
    })

    modeNode:Insert({ template = TEMPLATE.INFO, text = TEXT.ALWAYS_VISIBLE })
    for _, excludeKey in ipairs(ns.EXCLUDE_ORDER) do
        InsertExcludeToggle(modeNode, mode, excludeKey)
    end
    for _, excludeKey in ipairs(mode.extraExcludes or {}) do
        InsertExcludeToggle(modeNode, mode, excludeKey)
    end
end

local SettingsPage = {}

-- The list shows exactly the modes of the running client. In Forever there is no housing row.
function SettingsPage.CreateDataProvider()
    local dataProvider = CreateTreeDataProvider()
    dataProvider:Insert({ template = TEMPLATE.SEPARATOR, label = TEXT.SECTION_FADING })
    for _, mode in ipairs(ns.Modes.GetAvailable()) do
        InsertMode(dataProvider, mode)
    end
    return dataProvider
end

ns.SettingsPage = SettingsPage
