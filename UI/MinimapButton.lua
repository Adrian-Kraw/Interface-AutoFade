local _, ns = ...

local Theme = ns.Theme
local COLORS = Theme.COLORS
local TEXT = ns.TEXT

local BUTTON_SIZE = 36
local ICON_SIZE = 30
local RADIUS = 99
local FRAME_LEVEL = 8
local FRAME_STRATA = "MEDIUM"
local TOOLTIP_ANCHOR = "ANCHOR_LEFT"
local CIRCLE_MASK_TEXTURE = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local GOLD_RING_ATLAS = "talents-node-choiceflyout-circle-yellow"
local DRAG_BUTTON = "LeftButton"
local CLICK_REGISTRATION = "AnyUp"
local TOOLTIP_LINE_COLOR = 0.7

local MinimapButton = {}

local function UpdatePosition(button)
    local angle = math.rad(ns.Database.GetMinimapAngle())
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * RADIUS, math.sin(angle) * RADIUS)
end

-- Turns the cursor position into an angle around the minimap center.
local function UpdateAngleFromCursor(button)
    local mapX, mapY = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local cursorX, cursorY = GetCursorPosition()
    local angle = math.deg(math.atan2(cursorY / scale - mapY, cursorX / scale - mapX))
    ns.Database.SetMinimapAngle(angle)
    UpdatePosition(button)
end

local function ShowTooltip(button)
    local accent = COLORS.ACCENT
    GameTooltip:SetOwner(button, TOOLTIP_ANCHOR)
    GameTooltip:SetText(TEXT.TITLE, accent.r, accent.g, accent.b, accent.a)
    GameTooltip:AddLine(TEXT.MINIMAP_CLICK, TOOLTIP_LINE_COLOR, TOOLTIP_LINE_COLOR, TOOLTIP_LINE_COLOR)
    GameTooltip:AddLine(TEXT.MINIMAP_DRAG, TOOLTIP_LINE_COLOR, TOOLTIP_LINE_COLOR, TOOLTIP_LINE_COLOR)
    GameTooltip:Show()
end

function MinimapButton.Create()
    local button = CreateFrame("Button", nil, Minimap)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameStrata(FRAME_STRATA)
    button:SetFixedFrameStrata(true)
    button:SetFrameLevel(FRAME_LEVEL)
    button:SetFixedFrameLevel(true)
    button:RegisterForClicks(CLICK_REGISTRATION)
    button:RegisterForDrag(DRAG_BUTTON)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("CENTER")
    icon:SetTexture(ns.ICON_TEXTURE)

    local mask = button:CreateMaskTexture()
    mask:SetAllPoints(icon)
    mask:SetTexture(CIRCLE_MASK_TEXTURE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    icon:AddMaskTexture(mask)

    local ring = button:CreateTexture(nil, "OVERLAY")
    ring:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    ring:SetPoint("CENTER")
    ring:SetAtlas(GOLD_RING_ATLAS)

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == DRAG_BUTTON then
            ns.MainWindow.Toggle()
        end
    end)
    button:SetScript("OnEnter", ShowTooltip)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", UpdateAngleFromCursor)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    UpdatePosition(button)
end

ns.MinimapButton = MinimapButton
