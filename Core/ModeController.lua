local _, ns = ...

local ALPHA = ns.ALPHA
local PERCENT = ns.PERCENT
local SETTING = ns.SETTING
local ENTERING_WORLD_DELAY = ns.ENTERING_WORLD_DELAY

-- Idle means the interface is faded out. Active means it is shown at the set transparency.
local STATE = {
    IDLE = "idle",
    ACTIVE = "active",
}

local function CancelTimer(timer)
    if timer then
        timer:Cancel()
    end
    return nil
end

-- One controller per mode. It decides when the mode fades the interface out and in.
local function CreateController(definition)
    local modeKey = definition.key
    local controller = { key = modeKey }
    local state = STATE.IDLE
    local moveTimer
    local idleTimer
    local chatTimer

    local function GetSetting(setting)
        return ns.Database.GetModeSetting(modeKey, setting)
    end

    local function IsEnabled()
        return GetSetting(SETTING.ENABLED)
    end

    -- A mode only reacts while it is enabled, the player is in its place and not in combat.
    local function CanRun()
        return IsEnabled() and definition.appliesHere() and not ns.Fader.IsInCombat()
    end

    local function CancelAllTimers()
        moveTimer = CancelTimer(moveTimer)
        idleTimer = CancelTimer(idleTimer)
        chatTimer = CancelTimer(chatTimer)
    end

    local function GoIdle()
        state = STATE.IDLE
        ns.Fader.SetModeAlpha(modeKey, ALPHA.HIDDEN)
    end

    local function GoActive()
        state = STATE.ACTIVE
        chatTimer = CancelTimer(chatTimer)
        ns.Fader.SetModeAlpha(modeKey, GetSetting(SETTING.ALPHA) / PERCENT)
    end

    local function StartIdleCountdown()
        idleTimer = CancelTimer(idleTimer)
        idleTimer = C_Timer.NewTimer(GetSetting(SETTING.IDLE_DELAY), function()
            idleTimer = nil
            if CanRun() then
                GoIdle()
            end
        end)
    end

    function controller.OnChatEvent()
        if not CanRun() or state ~= STATE.IDLE then
            return
        end
        chatTimer = CancelTimer(chatTimer)
        ns.Fader.ShowChat()
        chatTimer = C_Timer.NewTimer(GetSetting(SETTING.CHAT_DELAY), function()
            chatTimer = nil
            if CanRun() then
                ns.Fader.Apply()
            end
        end)
    end

    function controller.OnEnteringWorld()
        if not IsEnabled() then
            return
        end
        C_Timer.After(ENTERING_WORLD_DELAY, function()
            if CanRun() and state == STATE.IDLE then
                GoIdle()
            end
        end)
    end

    function controller.OnCombatStart()
        CancelAllTimers()
        ns.Fader.ClearMode(modeKey)
    end

    function controller.OnCombatEnd()
        if IsEnabled() and definition.appliesHere() then
            StartIdleCountdown()
        end
    end

    function controller.OnStartedMoving()
        if not IsEnabled() or ns.Fader.IsInCombat() then
            return
        end
        idleTimer = CancelTimer(idleTimer)
        moveTimer = CancelTimer(moveTimer)
        local delay = GetSetting(SETTING.MOVE_DELAY)
        if delay == 0 then
            if definition.appliesHere() then
                GoActive()
            end
            return
        end
        moveTimer = C_Timer.NewTimer(delay, function()
            moveTimer = nil
            if CanRun() then
                GoActive()
            end
        end)
    end

    function controller.OnStoppedMoving()
        moveTimer = CancelTimer(moveTimer)
        if not IsEnabled() or ns.Fader.IsInCombat() then
            return
        end
        if definition.appliesHere() and state == STATE.ACTIVE then
            StartIdleCountdown()
        end
    end

    -- While the interface is shown, a running idle timer must stay. Frequent zone events
    -- would otherwise cancel it again and again, and the interface would never fade.
    function controller.OnZoneChanged()
        if not IsEnabled() then
            return
        end
        if not definition.appliesHere() then
            CancelAllTimers()
            state = STATE.IDLE
            ns.Fader.ClearMode(modeKey)
            return
        end
        if state == STATE.IDLE and not ns.Fader.IsInCombat() then
            CancelAllTimers()
            GoIdle()
            StartIdleCountdown()
        end
    end

    function controller.SetEnabled(enabled)
        ns.Database.SetModeSetting(modeKey, SETTING.ENABLED, enabled)
        if enabled then
            if CanRun() then
                GoIdle()
                StartIdleCountdown()
            end
        else
            CancelAllTimers()
            state = STATE.IDLE
            ns.Fader.ClearMode(modeKey)
        end
    end

    -- Applies a changed transparency right away, but only while the interface is shown.
    function controller.ApplyAlpha()
        if IsEnabled() and state == STATE.ACTIVE then
            ns.Fader.SetModeAlpha(modeKey, GetSetting(SETTING.ALPHA) / PERCENT)
        end
    end

    return controller
end

local controllers = {}
for _, definition in ipairs(ns.Modes.GetAvailable()) do
    controllers[#controllers + 1] = CreateController(definition)
end

local ModeController = {}

function ModeController.GetAll()
    return controllers
end

function ModeController.Find(modeKey)
    for _, controller in ipairs(controllers) do
        if controller.key == modeKey then
            return controller
        end
    end
    return nil
end

ns.ModeController = ModeController
