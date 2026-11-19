local _, ns = ...

local Theme = ns.Theme
local COLORS = Theme.COLORS
local TEXT = ns.TEXT

local BUTTON_SIZE = 31
-- Minimap button collectors only take buttons with a name. The name does not contain LibDBIcon
-- on purpose. Collectors such as Leatrix Plus skip those names, because they expect them in the library list.
local BUTTON_NAME = "InterfaceAutoFadeMinimapButton"
-- The button sits just outside the minimap edge, like the buttons of most other addons.
local EDGE_OFFSET = 5
local FRAME_LEVEL = 8
local FRAME_STRATA = "MEDIUM"
local TOOLTIP_ANCHOR = "ANCHOR_LEFT"
local DRAG_BUTTON = "LeftButton"
local CLICK_REGISTRATION = "AnyUp"
local TOOLTIP_LINE_COLOR = 0.7

-- The same game textures as in LibDBIcon, the library behind most minimap buttons, so this
-- button looks like theirs. The numbers are file ids of Interface\Minimap\MiniMap-TrackingBorder,
-- Interface\Minimap\UI-Minimap-Background and Interface\Minimap\UI-Minimap-ZoomButton-Highlight.
local BORDER_TEXTURE = 136430
local BACKGROUND_TEXTURE = 136467
local HIGHLIGHT_TEXTURE = 136477

-- Size and place of the three layers. LibDBIcon picks the values by the game project, and so does this file.
local LAYOUT_MAINLINE = {
    border = { size = 50, point = "TOPLEFT", x = 0, y = 0 },
    background = { size = 24, point = "CENTER", x = 0, y = 0 },
    icon = { size = 18, point = "CENTER", x = 0, y = 0 },
}
local LAYOUT_OTHER = {
    border = { size = 53, point = "TOPLEFT", x = 0, y = 0 },
    background = { size = 20, point = "TOPLEFT", x = 7, y = -5 },
    icon = { size = 17, point = "TOPLEFT", x = 7, y = -6 },
}
local LAYOUT = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and LAYOUT_MAINLINE or LAYOUT_OTHER

local MinimapButton = {}

local function UpdatePosition(button)
    local angle = math.rad(ns.Database.GetMinimapAngle())
    local radius = Minimap:GetWidth() / 2 + EDGE_OFFSET
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
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

local function CreateLayer(button, drawLayer, texture, spec)
    local layer = button:CreateTexture(nil, drawLayer)
    layer:SetSize(spec.size, spec.size)
    layer:SetTexture(texture)
    layer:SetPoint(spec.point, button, spec.point, spec.x, spec.y)
    return layer
end

function MinimapButton.Create()
    local button = CreateFrame("Button", BUTTON_NAME, Minimap)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameStrata(FRAME_STRATA)
    button:SetFixedFrameStrata(true)
    button:SetFrameLevel(FRAME_LEVEL)
    button:SetFixedFrameLevel(true)
    button:RegisterForClicks(CLICK_REGISTRATION)
    button:RegisterForDrag(DRAG_BUTTON)
    button:SetHighlightTexture(HIGHLIGHT_TEXTURE)

    CreateLayer(button, "OVERLAY", BORDER_TEXTURE, LAYOUT.border)
    CreateLayer(button, "BACKGROUND", BACKGROUND_TEXTURE, LAYOUT.background)
    CreateLayer(button, "ARTWORK", ns.ICON_TEXTURE, LAYOUT.icon)

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
        -- A collector bar puts the button under another parent. It must not jump back to the minimap then.
        if self:GetParent() ~= Minimap then
            return
        end
        self:SetScript("OnUpdate", UpdateAngleFromCursor)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    UpdatePosition(button)
end

ns.MinimapButton = MinimapButton
