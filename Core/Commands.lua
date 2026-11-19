local _, ns = ...

local TEXT = ns.TEXT

local COMMAND_STATUS = "status"
local COMMAND_ENABLE = "enable"
local COMMAND_DISABLE = "disable"
local COMMAND_ALPHA = "alpha"

local function SplitWords(message)
    local words = {}
    for word in string.gmatch(message, "%S+") do
        words[#words + 1] = string.lower(word)
    end
    return words
end

local function JoinAvailableModeKeys()
    local keys = {}
    for _, mode in ipairs(ns.Modes.GetAvailable()) do
        keys[#keys + 1] = mode.key
    end
    return table.concat(keys, ", ")
end

local function PrintModeStatus(mode)
    local settings = ns.Database.GetModeSettings(mode.key)
    local state = settings.enabled and TEXT.ENABLED or TEXT.DISABLED
    ns.Chat.Print(string.format(TEXT.MODE_STATUS, TEXT.MODE_LABEL[mode.key], state, settings.alpha * ns.PERCENT))
end

-- Prints a hint and returns nil when the mode does not exist in this client.
local function FindModeOrReport(modeKey)
    local mode = ns.Modes.Find(modeKey)
    if not mode then
        ns.Chat.Print(string.format(TEXT.UNKNOWN_MODE, modeKey or "", JoinAvailableModeKeys()))
    end
    return mode
end

local function ShowStatus()
    local activeMode = ns.Modes.GetActive()
    local activeLabel = activeMode and TEXT.MODE_LABEL[activeMode.key] or TEXT.NO_ACTIVE_MODE
    ns.Chat.Print(string.format(TEXT.STATUS_HEADER, ns.Client.current, activeLabel))
    for _, mode in ipairs(ns.Modes.GetAvailable()) do
        PrintModeStatus(mode)
    end
end

local function SetModeEnabled(modeKey, enabled)
    local mode = FindModeOrReport(modeKey)
    if not mode then
        return
    end
    ns.Database.SetModeEnabled(mode.key, enabled)
    ns.Fader.Apply()
    PrintModeStatus(mode)
end

local function SetModeAlpha(modeKey, percentText)
    local mode = FindModeOrReport(modeKey)
    if not mode then
        return
    end
    local percent = tonumber(percentText)
    if not percent then
        ns.Chat.Print(TEXT.INVALID_ALPHA)
        return
    end
    ns.Database.SetModeAlpha(mode.key, percent / ns.PERCENT)
    ns.Fader.Apply()
    PrintModeStatus(mode)
end

local function HandleCommand(message)
    local words = SplitWords(message)
    local command = words[1]
    if command == nil or command == COMMAND_STATUS then
        ShowStatus()
    elseif command == COMMAND_ENABLE then
        SetModeEnabled(words[2], true)
    elseif command == COMMAND_DISABLE then
        SetModeEnabled(words[2], false)
    elseif command == COMMAND_ALPHA then
        SetModeAlpha(words[2], words[3])
    else
        ns.Chat.Print(TEXT.USAGE)
    end
end

local Commands = {}

-- Called from Main.lua once the database exists, so the handler never runs too early.
function Commands.Register()
    _G["SLASH_" .. ns.SLASH_KEY .. "1"] = ns.SLASH_COMMAND
    SlashCmdList[ns.SLASH_KEY] = HandleCommand
end

ns.Commands = Commands
