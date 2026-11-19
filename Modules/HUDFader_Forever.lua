local _, ns = ...

if ns.Client.current ~= ns.CLIENT.FOREVER then
    return
end

-- Modules/Interface/HUDFader.lua
-- Two independent modes: resting zones (mode1) and open world (mode2).
-- Both can be active at the same time. The final alpha is the maximum of all active modes.
-- Combat: immediately full alpha, visible the whole time.
-- Instances: no mode applies.

local M = {}
ns.HUDFader = M

-- ============================================================
-- UI elements (SetAlpha fade)
-- ============================================================
local ELEMENTS = {
    { key = "actionBars", frames = function()
        local f = {}
        for _, n in ipairs({ "MainActionBar","MultiBarBottomLeft","MultiBarBottomRight",
            "MultiBarRight","MultiBarLeft","MultiBar5","MultiBar6","MultiBar7",
            "StanceBar","PetActionBar" }) do
            if _G[n] then f[#f+1] = _G[n] end
        end
        return f
    end },
    { key = "microMenu", frames = function()
        local f = {}
        for _, n in ipairs({ "CharacterMicroButton","ProfessionMicroButton",
            "PlayerSpellsMicroButton","AchievementMicroButton","QuestLogMicroButton",
            "GuildMicroButton","LFDMicroButton","CollectionsMicroButton",
            "EJMicroButton","StoreMicroButton","MainMenuMicroButton",
            "HousingMicroButton",
            -- Forever only
            "SpellbookMicroButton","TalentMicroButton","LegacyMicroButton",
            "HelpMicroButton" }) do
            if _G[n] then f[#f+1] = _G[n] end
        end
        if MicroButtonAndBagsBar then f[#f+1] = MicroButtonAndBagsBar end
        -- Forever draws a border and background on the menu frame itself
        if MicroMenu then f[#f+1] = MicroMenu end
        return f
    end },
    { key = "bags", frames = function()
        local f = {}
        for _, n in ipairs({ "MainMenuBarBackpackButton","CharacterBag0Slot",
            "CharacterBag1Slot","CharacterBag2Slot","CharacterBag3Slot","BagsBar" }) do
            if _G[n] then f[#f+1] = _G[n] end
        end
        return f
    end },
    { key = "minimap", frames = function()
        -- Only fade MinimapCluster. Minimap inherits the parent alpha automatically.
        return MinimapCluster and {MinimapCluster} or {}
    end },
    { key = "buffs",        frames = function() return BuffFrame             and {BuffFrame}             or {} end },
    { key = "debuffs",      frames = function() return DebuffFrame           and {DebuffFrame}           or {} end },
    { key = "playerFrame",  frames = function() return PlayerFrame           and {PlayerFrame}           or {} end },
    { key = "targetFrame",  frames = function() return TargetFrame           and {TargetFrame}           or {} end },
    { key = "focusFrame",   frames = function() return FocusFrame            and {FocusFrame}            or {} end },
    { key = "partyFrame",   frames = function() return CompactPartyFrame     and {CompactPartyFrame}     or {} end },
    { key = "objectives",   frames = function() return ObjectiveTrackerFrame and {ObjectiveTrackerFrame} or {} end },
    { key = "repBar",       frames = function() return StatusTrackingBarManager and {StatusTrackingBarManager} or {} end },
    { key = "expansionBtn", frames = function()
        local f = {}
        for _, n in ipairs({ "ExpansionLandingPageMinimapButton", "GarrisonLandingPageMinimapButton" }) do
            if _G[n] then f[#f+1] = _G[n] end
        end
        return f
    end },
    { key = "socialBtn",   frames = function() return QuickJoinToastButton and {QuickJoinToastButton} or {} end },
    { key = "chatCopyBtn", frames = function()
        local b = _G["AklimeMod_ChatCopyBtn"]
        return b and {b} or {}
    end },
    { key = "damageMeter", frames = function()
        local f = {}
        if DamageMeter then f[#f+1] = DamageMeter end
        for i = 1, 5 do
            local sw = _G["DamageMeterSessionWindow" .. i]
            if sw then f[#f+1] = sw end
        end
        return f
    end },
}

local CHAT_EVENTS = {
    "CHAT_MSG_SAY","CHAT_MSG_YELL","CHAT_MSG_EMOTE","CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_WHISPER","CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_PARTY","CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID","CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_GUILD","CHAT_MSG_OFFICER",
    "CHAT_MSG_CHANNEL","CHAT_MSG_INSTANCE_CHAT","CHAT_MSG_INSTANCE_CHAT_LEADER",
}

-- Battle.net whispers. They are registered apart, so a client without these events cannot break the loading.
local BN_CHAT_EVENTS = {
    "CHAT_MSG_BN_WHISPER","CHAT_MSG_BN_WHISPER_INFORM",
}

local MOVE_ACTIVATE_DELAY = 2
local IDLE_DELAY          = 12
local CHAT_SHOW_DURATION  = 15

-- ============================================================
-- Fade-Engine
-- ============================================================
local fadeTargets = {}
local FADE_SPEED  = 1.5

local ticker = CreateFrame("Frame")
ticker:SetScript("OnUpdate", function(_, elapsed)
    for frame, target in pairs(fadeTargets) do
        local cur = frame:GetAlpha()
        if math.abs(cur - target) < 0.01 then
            frame:SetAlpha(target)
            fadeTargets[frame] = nil
        else
            local step = FADE_SPEED * elapsed
            frame:SetAlpha(cur + (target > cur and step or -step))
        end
    end
end)

local function FadeTo(frame, alpha)
    if not frame then return end
    fadeTargets[frame] = math.max(0, math.min(1, alpha))
end

-- ============================================================
-- Minimap overlays
-- Nameless MinimapCluster children (player arrow, quest blobs,
-- merchant icons) ignore the parent alpha. Solution: Hide() + OnShow hook.
-- ============================================================
local minimapIdleActive  = false
local hookedOverlays     = {}
local currentHidden      = {}

local function HideMinimapOverlays()
    if minimapIdleActive then return end  -- already hidden, no second wipe
    minimapIdleActive = true
    wipe(currentHidden)
    if not MinimapCluster then return end

    for _, child in ipairs({ MinimapCluster:GetChildren() }) do
        local name = child:GetName()
        if not name or name == "" then
            local ok, shown = pcall(function() return child:IsShown() end)
            if ok and shown then
                if not hookedOverlays[child] then
                    hookedOverlays[child] = true
                    child:HookScript("OnShow", function(self)
                        if minimapIdleActive then self:Hide() end
                    end)
                end
                currentHidden[#currentHidden + 1] = child
                child:Hide()
            end
        end
    end
end

local function ShowMinimapOverlays()
    if not minimapIdleActive then return end  -- already visible
    minimapIdleActive = false
    for _, child in ipairs(currentHidden) do
        pcall(function() child:Show() end)
    end
    wipe(currentHidden)
end

-- ============================================================
-- Helpers
-- ============================================================
-- Every chat window counts, also hidden tabs and temporary windows such as whisper tabs.
-- A tab that is hidden while the interface fades would otherwise appear at full alpha when selected.
-- Blizzard numbers temporary windows above MaxChatWindows, so the range must reach past that number.
local TEMPORARY_CHAT_WINDOW_ALLOWANCE = 40
local MAX_CHAT_FRAMES = (Constants and Constants.ChatFrameConstants and Constants.ChatFrameConstants.MaxChatWindows or 10) + TEMPORARY_CHAT_WINDOW_ALLOWANCE

local function GetChatFrames()
    local f = {}
    for i = 1, MAX_CHAT_FRAMES do
        local cf = _G["ChatFrame" .. i]
        if cf then f[#f+1] = cf end
        -- The input box does not follow the chat frame alpha and needs its own fade
        local editBox = _G["ChatFrame" .. i .. "EditBox"]
        if cf and editBox then f[#f+1] = editBox end
    end
    if GeneralDockManager then f[#f+1] = GeneralDockManager end
    return f
end

-- True while the player types in a chat input box. The chat must not fade away under the text.
local function IsTyping()
    for i = 1, MAX_CHAT_FRAMES do
        local editBox = _G["ChatFrame" .. i .. "EditBox"]
        if editBox and editBox:HasFocus() then return true end
    end
    return false
end

-- True while the mouse is over a shown chat window or the tab bar. The chat then shows, like for a new message.
local function IsMouseOverChat()
    for _, frame in ipairs(GetChatFrames()) do
        if frame:IsShown() and frame:IsMouseOver() then return true end
    end
    return false
end

local function CancelTimer(t)
    if t then t:Cancel() end
    return nil
end

-- ============================================================
-- Unified Alpha
-- Each mode reports its desired alpha (nil = not active).
-- Final alpha = maximum of all reported values.
-- No modes active: full alpha (1.0).
-- ============================================================
local modeAlphas = {}
local inCombat   = false

-- Mapping: ELEMENTS key -> DB exclude key
local EXCLUDE_KEY = {
    actionBars  = "actionBars",
    microMenu   = "microMenu",
    bags        = "bags",
    minimap     = "minimap",
    objectives  = "objectives",
    playerFrame = "unitFrames",
    targetFrame = "unitFrames",
    focusFrame  = "unitFrames",
    partyFrame  = "unitFrames",
    chatCopyBtn = "chat",
    socialBtn   = "chat",
    buffs       = "buffs",
    debuffs     = "buffs",
    repBar      = "repBar",
    damageMeter = "damageMeter",
}

-- Returns true if the excludeKey is marked as an exception in an active mode
local function IsExcluded(excludeKey)
    if not excludeKey then return false end
    for dbKey in pairs(modeAlphas) do
        local db = InterfaceAutoFadeDB and InterfaceAutoFadeDB.interfaceFade and InterfaceAutoFadeDB.interfaceFade[dbKey]
        if db and db.exclude and db.exclude[excludeKey] then return true end
    end
    return false
end

-- Returns true if an active mode has the hover option on
local function IsHoverRevealOn()
    for dbKey in pairs(modeAlphas) do
        local db = InterfaceAutoFadeDB and InterfaceAutoFadeDB.interfaceFade and InterfaceAutoFadeDB.interfaceFade[dbKey]
        if db and db.hoverReveal then return true end
    end
    return false
end

-- True while the mouse is over a shown frame of this element
local function IsMouseOverElement(element)
    local ok, frames = pcall(element.frames)
    if not ok or not frames then return false end
    for _, f in ipairs(frames) do
        if f:IsShown() then
            local okOver, isOver = pcall(f.IsMouseOver, f)
            if okOver and isOver then return true end
        end
    end
    return false
end

-- Keys of the interface elements under the mouse. The chat counts as an element of its own.
local function GetHoveredKeys()
    local hovered = {}
    for _, el in ipairs(ELEMENTS) do
        if IsMouseOverElement(el) then hovered[el.key] = true end
    end
    if IsMouseOverChat() then hovered.chat = true end
    return hovered
end

local function ApplyUnified()
    if inCombat then return end
    local maxAlpha = nil
    for _, a in pairs(modeAlphas) do
        if maxAlpha == nil or a > maxAlpha then maxAlpha = a end
    end
    if maxAlpha == nil then maxAlpha = 1.0 end

    -- With the hover option, an element under the mouse is shown while the rest stays faded
    local hovered = IsHoverRevealOn() and GetHoveredKeys() or {}

    for _, el in ipairs(ELEMENTS) do
        local alpha = (IsExcluded(EXCLUDE_KEY[el.key]) or hovered[el.key]) and 1.0 or maxAlpha
        local ok, frames = pcall(el.frames)
        if ok and frames then
            for _, f in ipairs(frames) do FadeTo(f, alpha) end
        end
    end
    -- The chat stays visible while the player types or points at it
    local chatAlpha = (IsExcluded("chat") or IsTyping() or hovered.chat) and 1.0 or maxAlpha
    for _, cf in ipairs(GetChatFrames()) do FadeTo(cf, chatAlpha) end

    if maxAlpha == 0 and not IsExcluded("minimap") and not hovered.minimap then
        HideMinimapOverlays()
    else
        if Minimap then Minimap:SetAlpha(1.0) end
        ShowMinimapOverlays()
    end
end

local function GoFullAll()
    wipe(modeAlphas)
    if Minimap then Minimap:SetAlpha(1.0) end
    ShowMinimapOverlays()
    for _, el in ipairs(ELEMENTS) do
        for _, f in ipairs(el.frames()) do FadeTo(f, 1.0) end
    end
    for _, cf in ipairs(GetChatFrames()) do FadeTo(cf, 1.0) end
end

-- ============================================================
-- Mode factory
-- dbKey:     key in InterfaceAutoFadeDB.interfaceFade (e.g. "mode1")
-- zoneCheck: function() -> bool  (true = mode applies in this zone)
-- ============================================================
local function CreateMode(dbKey, zoneCheck)
    local mode      = {}
    local state     = "idle"
    local moveTimer = nil
    local idleTimer = nil
    local chatTimer = nil

    local function getDB()
        return InterfaceAutoFadeDB and InterfaceAutoFadeDB.interfaceFade and InterfaceAutoFadeDB.interfaceFade[dbKey]
    end

    local function isEnabled()
        local db = getDB()
        return db and db.enabled == true
    end

    local function getActiveAlpha()
        local db = getDB()
        return (db and db.alpha or 60) / 100
    end

    local function setAlpha(a)
        modeAlphas[dbKey] = a
        ApplyUnified()
    end

    local function clearAlpha()
        modeAlphas[dbKey] = nil
        ApplyUnified()
    end

    local function goIdle()
        state = "idle"
        setAlpha(0)
    end

    local function goActive()
        state = "active"
        chatTimer = CancelTimer(chatTimer)
        setAlpha(getActiveAlpha())
    end

    local function startIdleCountdown()
        idleTimer = CancelTimer(idleTimer)
        local db = getDB()
        local delay = (db and db.idleDelay) or IDLE_DELAY
        idleTimer = C_Timer.NewTimer(delay, function()
            idleTimer = nil
            if isEnabled() and zoneCheck() and not inCombat then
                goIdle()
            end
        end)
    end

    function mode:OnChatEvent()
        if not isEnabled() or inCombat or not zoneCheck() then return end
        if state ~= "idle" then return end
        chatTimer = CancelTimer(chatTimer)
        for _, cf in ipairs(GetChatFrames()) do FadeTo(cf, 1.0) end
        local db = getDB()
        local delay = (db and db.chatDelay) or CHAT_SHOW_DURATION
        chatTimer = C_Timer.NewTimer(delay, function()
            chatTimer = nil
            if isEnabled() and zoneCheck() and not inCombat then
                ApplyUnified()
            end
        end)
    end

    function mode:OnEnteringWorld()
        if not isEnabled() then return end
        C_Timer.After(2, function()
            if isEnabled() and zoneCheck() and not inCombat and state == "idle" then
                goIdle()
            end
        end)
    end

    function mode:OnCombatStart()
        moveTimer = CancelTimer(moveTimer)
        idleTimer = CancelTimer(idleTimer)
        chatTimer = CancelTimer(chatTimer)
        clearAlpha()
    end

    function mode:OnCombatEnd()
        if not isEnabled() then return end
        if zoneCheck() then
            startIdleCountdown()
        end
    end

    function mode:OnStartedMoving()
        if not isEnabled() or inCombat then return end
        idleTimer = CancelTimer(idleTimer)
        moveTimer = CancelTimer(moveTimer)
        local db = getDB()
        local delay = (db and db.moveDelay) or MOVE_ACTIVATE_DELAY
        if delay == 0 then
            if zoneCheck() then goActive() end
            return
        end
        moveTimer = C_Timer.NewTimer(delay, function()
            moveTimer = nil
            if isEnabled() and zoneCheck() and not inCombat then
                goActive()
            end
        end)
    end

    function mode:OnStoppedMoving()
        moveTimer = CancelTimer(moveTimer)
        if not isEnabled() or inCombat then return end
        if zoneCheck() and state == "active" then
            startIdleCountdown()
        end
    end

    function mode:OnZoneChanged()
        if not isEnabled() then return end
        if not zoneCheck() then
            moveTimer = CancelTimer(moveTimer)
            idleTimer = CancelTimer(idleTimer)
            chatTimer = CancelTimer(chatTimer)
            state = "idle"
            clearAlpha()
            return
        end
        -- Still in a zone of this mode. While the interface is shown, the running idle
        -- timer must stay, otherwise frequent zone events would cancel it and the
        -- interface would never fade after the set time.
        if state == "idle" and not inCombat then
            moveTimer = CancelTimer(moveTimer)
            idleTimer = CancelTimer(idleTimer)
            chatTimer = CancelTimer(chatTimer)
            goIdle()
            startIdleCountdown()
        end
    end

    function mode:SetEnabled(v)
        local db = getDB()
        if db then db.enabled = v end
        if v then
            if zoneCheck() and not inCombat then
                state = "idle"
                goIdle()
                startIdleCountdown()
            end
        else
            moveTimer = CancelTimer(moveTimer)
            idleTimer = CancelTimer(idleTimer)
            chatTimer = CancelTimer(chatTimer)
            state = "idle"
            clearAlpha()
        end
    end

    function mode:IsEnabled()
        return isEnabled()
    end

    function mode:ApplyAlpha()
        if not isEnabled() or state ~= "active" then return end
        setAlpha(getActiveAlpha())
    end

    return mode
end

-- ============================================================
-- Modes
-- ============================================================
local Mode1 = CreateMode("mode1", function()
    return IsResting() and not IsInInstance()
end)

local Mode2 = CreateMode("mode2", function()
    return not IsResting() and not IsInInstance()
end)

local ALL_MODES = { Mode1, Mode2 }

-- ============================================================
-- Events
-- ============================================================
local isChatEvent = {}
for _, ev in ipairs(CHAT_EVENTS) do isChatEvent[ev] = true end

local ef = CreateFrame("Frame")
ef:RegisterEvent("PLAYER_ENTERING_WORLD")
ef:RegisterEvent("PLAYER_STARTED_MOVING")
ef:RegisterEvent("PLAYER_STOPPED_MOVING")
ef:RegisterEvent("PLAYER_REGEN_DISABLED")
ef:RegisterEvent("PLAYER_REGEN_ENABLED")
-- Only for the own character, otherwise AFK changes of other players cancel the timers
ef:RegisterUnitEvent("PLAYER_FLAGS_CHANGED", "player")
ef:RegisterEvent("ZONE_CHANGED_INDOORS")
ef:RegisterEvent("ZONE_CHANGED_NEW_AREA")
for _, ev in ipairs(CHAT_EVENTS) do ef:RegisterEvent(ev) end
for _, ev in ipairs(BN_CHAT_EVENTS) do
    isChatEvent[ev] = true
    pcall(ef.RegisterEvent, ef, ev)
end

ef:SetScript("OnEvent", function(_, event)
    if isChatEvent[event] then
        for _, m in ipairs(ALL_MODES) do m:OnChatEvent() end
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        inCombat = false
        -- Reset the minimap idle state, otherwise the OnShow hooks hide the overlays again
        ShowMinimapOverlays()
        if Minimap then Minimap:SetAlpha(1.0) end
        for _, m in ipairs(ALL_MODES) do m:OnEnteringWorld() end

    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        for _, m in ipairs(ALL_MODES) do m:OnCombatStart() end
        GoFullAll()

    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        for _, m in ipairs(ALL_MODES) do m:OnCombatEnd() end

    elseif event == "PLAYER_STARTED_MOVING" then
        for _, m in ipairs(ALL_MODES) do m:OnStartedMoving() end

    elseif event == "PLAYER_STOPPED_MOVING" then
        for _, m in ipairs(ALL_MODES) do m:OnStoppedMoving() end

    elseif event == "PLAYER_FLAGS_CHANGED"
        or event == "ZONE_CHANGED_INDOORS"
        or event == "ZONE_CHANGED_NEW_AREA" then
        for _, m in ipairs(ALL_MODES) do m:OnZoneChanged() end
    end
end)

-- ============================================================
-- Chat windows created later and typing
-- Whisper windows are created later and start at full alpha. They get the faded alpha right away.
-- Typing starts or ends when an input box gains or loses focus. The chat is then shown or faded again.
-- Without any wish from a mode there is nothing to fade, so the interface stays untouched.
-- ============================================================
local hookedEditBoxes = {}

local function OnChatChanged()
    if next(modeAlphas) then ApplyUnified() end
end

local function HookEditBoxes()
    for i = 1, MAX_CHAT_FRAMES do
        local editBox = _G["ChatFrame" .. i .. "EditBox"]
        if editBox and not hookedEditBoxes[editBox] then
            hookedEditBoxes[editBox] = true
            editBox:HookScript("OnEditFocusGained", OnChatChanged)
            editBox:HookScript("OnEditFocusLost", OnChatChanged)
        end
    end
end

local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_LOGIN")
hookFrame:SetScript("OnEvent", function()
    HookEditBoxes()
    hooksecurefunc("FCF_OpenTemporaryWindow", function()
        HookEditBoxes()
        OnChatChanged()
    end)
end)

-- The mouse position is polled instead of hooked, so elements created later need no extra hook.
-- Only a change of the elements under the mouse triggers a new calculation.
local HOVER_CHECK_INTERVAL = 0.1
local hoverElapsed = 0
local lastHoverSignature = ""
local hoverFrame = CreateFrame("Frame")

-- Joins the hovered keys in a fixed order, so equal states give equal text.
local function GetHoverSignature()
    local hovered = GetHoveredKeys()
    local parts = {}
    for _, el in ipairs(ELEMENTS) do
        if hovered[el.key] then parts[#parts + 1] = el.key end
    end
    if hovered.chat then parts[#parts + 1] = "chat" end
    return table.concat(parts, ",")
end

hoverFrame:SetScript("OnUpdate", function(_, elapsed)
    hoverElapsed = hoverElapsed + elapsed
    if hoverElapsed < HOVER_CHECK_INTERVAL then return end
    hoverElapsed = 0
    if not next(modeAlphas) or not IsHoverRevealOn() then
        lastHoverSignature = ""
        return
    end
    local signature = GetHoverSignature()
    if signature ~= lastHoverSignature then
        lastHoverSignature = signature
        ApplyUnified()
    end
end)

-- ============================================================
-- Debug
-- ============================================================
SLASH_IAFHUD1 = "/iafhud"
SlashCmdList["IAFHUD"] = function(input)
    if input == "zone" then
        print("|cFFFFD100HUDFader Zone:|r " .. (GetRealZoneText() or "?") ..
              " / Sub: " .. (GetSubZoneText() or "?"))
        local inInst, instType = IsInInstance()
        print("  IsInInstance: " .. tostring(inInst) .. "  Typ: " .. tostring(instType))
        return
    end
    local function scanFrame(label, frame)
        if not frame then print("  " .. label .. ": nicht gefunden"); return end
        print(string.format("|cFFFFD100%s|r  alpha=%.2f", label, frame:GetAlpha()))
        local count = 0
        for _, child in ipairs({ frame:GetChildren() }) do
            count = count + 1
            local name  = child:GetName() or "(kein Name)"
            local shown = child:IsShown() and "SHOWN" or "hidden"
            local alpha = string.format("%.2f", child:GetAlpha())
            local okW, w = pcall(function() return child:GetWidth() end)
            local okH, h = pcall(function() return child:GetHeight() end)
            local size  = (okW and okH) and string.format("%dx%d", w, h) or "?"
            print(string.format("  [%d] %-45s %s  alpha=%s  size=%s", count, name, shown, alpha, size))
        end
        print(string.format("  Gesamt: %d Kinder", count))
    end
    scanFrame("MinimapCluster", MinimapCluster)
    scanFrame("Minimap",        Minimap)
end

-- ============================================================
-- API
-- ============================================================
function M:IsEnabled()    return Mode1:IsEnabled() end
function M:SetEnabled(v)  Mode1:SetEnabled(v) end
function M:ApplyAlpha()   Mode1:ApplyAlpha() end

function M:IsEnabled2()   return Mode2:IsEnabled() end
function M:SetEnabled2(v) Mode2:SetEnabled(v) end
function M:ApplyAlpha2()  Mode2:ApplyAlpha() end

function M:Refresh()      ApplyUnified() end
