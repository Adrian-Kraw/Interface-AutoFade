local _, ns = ...

local ALPHA = ns.ALPHA
local FADE_SPEED = ns.FADE_SPEED

-- Frame to target alpha. The driver only runs while a fade is in progress.
local targets = {}
local driver = CreateFrame("Frame")
driver:Hide()

-- The step is limited to the remaining distance, so a frame never overshoots its target.
local function Step(_, elapsed)
    local maxStep = FADE_SPEED * elapsed
    for frame, target in pairs(targets) do
        local current = frame:GetAlpha()
        local distance = target - current
        if math.abs(distance) <= maxStep then
            frame:SetAlpha(target)
            targets[frame] = nil
        else
            frame:SetAlpha(current + (distance > 0 and maxStep or -maxStep))
        end
    end
    if next(targets) == nil then
        driver:Hide()
    end
end

driver:SetScript("OnUpdate", Step)

local FadeEngine = {}

function FadeEngine.FadeTo(frame, alpha)
    targets[frame] = math.max(ALPHA.HIDDEN, math.min(ALPHA.FULL, alpha))
    driver:Show()
end

ns.FadeEngine = FadeEngine
