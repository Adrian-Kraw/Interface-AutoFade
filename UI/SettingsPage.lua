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

local function InsertSlider(modeNode, modeKey, slider)
    modeNode:Insert({
        template = TEMPLATE.SLIDER,
        label = slider.label,
        min = slider.limits.MIN,
        max = slider.limits.MAX,
        step = SLIDER_STEP,
        format = slider.format,
        getValue = function()
            return ns.Database.GetModeSetting(modeKey, slider.setting)
        end,
        setValue = function(value)
            ns.Database.SetModeSetting(modeKey, slider.setting, value)
            if slider.onChange then
                slider.onChange()
            end
        end,
    })
end

local function InsertExcludeToggle(modeNode, modeKey, excludeKey)
    modeNode:Insert({
        template = TEMPLATE.TOGGLE,
        name = TEXT.EXCLUDE_LABEL[excludeKey],
        getValue = function()
            return ns.Database.IsExcluded(modeKey, excludeKey)
        end,
        setValue = function(excluded)
            ns.Database.SetExcluded(modeKey, excludeKey, excluded)
            ns.Fader.Apply()
        end,
    })
end

local function InsertMode(dataProvider, mode)
    local modeKey = mode.key
    local controller = ns.ModeController.Find(modeKey)

    local modeNode = dataProvider:Insert({
        template = TEMPLATE.HEADER,
        name = TEXT.MODE_LABEL[modeKey],
        getEnabled = function()
            return ns.Database.GetModeSetting(modeKey, SETTING.ENABLED)
        end,
        setEnabled = controller.SetEnabled,
    })
    modeNode:SetCollapsed(true)

    InsertSlider(modeNode, modeKey, {
        label = TEXT.SLIDER_TRANSPARENCY,
        setting = SETTING.ALPHA,
        limits = LIMITS.ALPHA,
        format = FormatPercent,
        onChange = controller.ApplyAlpha,
    })
    InsertSlider(modeNode, modeKey, {
        label = TEXT.SLIDER_MOVE_DELAY,
        setting = SETTING.MOVE_DELAY,
        limits = LIMITS.MOVE_DELAY,
        format = FormatMoveDelay,
    })
    InsertSlider(modeNode, modeKey, {
        label = TEXT.SLIDER_IDLE_DELAY,
        setting = SETTING.IDLE_DELAY,
        limits = LIMITS.IDLE_DELAY,
        format = FormatSeconds,
    })
    InsertSlider(modeNode, modeKey, {
        label = TEXT.SLIDER_CHAT_DELAY,
        setting = SETTING.CHAT_DELAY,
        limits = LIMITS.CHAT_DELAY,
        format = FormatSeconds,
    })

    modeNode:Insert({ template = TEMPLATE.INFO, text = TEXT.ALWAYS_VISIBLE })
    for _, excludeKey in ipairs(ns.EXCLUDE_ORDER) do
        InsertExcludeToggle(modeNode, modeKey, excludeKey)
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
