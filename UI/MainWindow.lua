local addonName, ns = ...

local Theme = ns.Theme
local COLORS = Theme.COLORS
local TEXT = ns.TEXT
local ALPHA = ns.ALPHA

local WINDOW_STRATA = "DIALOG"
local DRAG_ALPHA = 0.75
local STONE_TEXTURE = "Interface\\FrameGeneral\\UI-Background-Rock"
local CIRCLE_MASK_ATLAS = "CircleMaskScalable"
local GOLD_RING_ATLAS = "talents-node-choiceflyout-circle-yellow"
local FONT_NORMAL = "GameFontNormal"
local FONT_LARGE = "GameFontNormalLarge"
local FONT_SMALL_DISABLED = "GameFontDisableSmall"

local PORTRAIT_SIZE = 52
local PORTRAIT_RING_SIZE = 58
local PORTRAIT_OFFSET = 10
local CLOSE_BUTTON_SIZE = 26
local CLOSE_BUTTON_OFFSET = 10
local TITLE_TOP = -13
local TITLE_LINE_TOP = -38
local TITLE_LINE_INSET = 10
local PANEL_MARGIN = 12
local PANEL_TOP = 46
local PANEL_BOTTOM = 30
local SCROLL_BOX_INSET = 4
local SCROLL_BOX_RIGHT_INSET = 22
local SCROLL_BAR_INSET = 6
local LIST_PADDING = 10
local LIST_SPACING = 4
local VERSION_LEFT = 14
local VERSION_BOTTOM = 10

local window = InterfaceAutoFadeFrame
local scrollBox
local contentBuilt = false

local function StyleWindow()
    window:SetFrameStrata(WINDOW_STRATA)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    table.insert(UISpecialFrames, window:GetName())
    Theme.ApplyFlatStyle(window, COLORS.WINDOW_BG, COLORS.WINDOW_BORDER)

    -- Stone background texture, tinted dark.
    local stone = window:CreateTexture(nil, "BACKGROUND")
    stone:SetPoint("TOPLEFT", 1, -1)
    stone:SetPoint("BOTTOMRIGHT", -1, 1)
    stone:SetTexture(STONE_TEXTURE, "REPEAT", "REPEAT")
    stone:SetHorizTile(true)
    stone:SetVertTile(true)
    local tint = COLORS.WINDOW_TEXTURE_TINT
    stone:SetVertexColor(tint.r, tint.g, tint.b, tint.a)

    -- The whole window is the drag area, there is no title bar.
    window:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
            self:SetAlpha(DRAG_ALPHA)
        end
    end)
    window:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
        self:SetAlpha(ALPHA.FULL)
    end)
end

local function CreateCloseButton()
    local button = CreateFrame("Button", nil, window, "BackdropTemplate")
    button:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    button:SetPoint("TOPRIGHT", -CLOSE_BUTTON_OFFSET, -CLOSE_BUTTON_OFFSET)
    Theme.ApplyFlatStyle(button, COLORS.CLOSE_BUTTON, COLORS.PANEL_BORDER)

    local label = button:CreateFontString(nil, "OVERLAY", FONT_NORMAL)
    label:SetPoint("CENTER")
    label:SetText(TEXT.CLOSE)

    local accent = COLORS.ACCENT
    local border = COLORS.PANEL_BORDER
    button:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(accent.r, accent.g, accent.b, accent.a)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
    end)
    button:SetScript("OnClick", function()
        window:Hide()
    end)
end

local function CreateVersionText()
    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
    local text = window:CreateFontString(nil, "OVERLAY", FONT_SMALL_DISABLED)
    text:SetPoint("BOTTOMLEFT", VERSION_LEFT, VERSION_BOTTOM)
    text:SetText(version ~= "" and ("v" .. version) or "")
end

-- Round portrait with a golden ring. It sticks out over the top left corner.
local function CreatePortrait()
    local portrait = window:CreateTexture(nil, "OVERLAY", nil, 2)
    portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
    portrait:SetPoint("TOPLEFT", -PORTRAIT_OFFSET, PORTRAIT_OFFSET)
    portrait:SetTexture(ns.ICON_TEXTURE)

    local mask = window:CreateMaskTexture()
    mask:SetAtlas(CIRCLE_MASK_ATLAS)
    mask:SetAllPoints(portrait)
    portrait:AddMaskTexture(mask)

    local ring = window:CreateTexture(nil, "OVERLAY", nil, 3)
    ring:SetSize(PORTRAIT_RING_SIZE, PORTRAIT_RING_SIZE)
    ring:SetPoint("CENTER", portrait, "CENTER")
    ring:SetAtlas(GOLD_RING_ATLAS)
end

local function CreateTitle()
    local title = window:CreateFontString(nil, "OVERLAY", FONT_LARGE)
    title:SetPoint("TOP", window, "TOP", 0, TITLE_TOP)
    title:SetText(TEXT.TITLE)
    Theme.SetTextColor(title, COLORS.ACCENT)

    local line = window:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", window, "TOPLEFT", TITLE_LINE_INSET, TITLE_LINE_TOP)
    line:SetPoint("TOPRIGHT", window, "TOPRIGHT", -TITLE_LINE_INSET, TITLE_LINE_TOP)
    Theme.SetTextureColor(line, COLORS.LINE)
end

-- Content panel with a scrolling tree list. The scroll bar sits inside the panel.
local function CreateContent()
    local panel = CreateFrame("Frame", nil, window, "BackdropTemplate")
    panel:SetPoint("TOPLEFT", PANEL_MARGIN, -PANEL_TOP)
    panel:SetPoint("BOTTOMRIGHT", -PANEL_MARGIN, PANEL_BOTTOM)
    Theme.ApplyFlatStyle(panel, COLORS.PANEL_BG, COLORS.PANEL_BORDER)

    local box = CreateFrame("Frame", nil, panel, "WowScrollBoxList")
    box:SetPoint("TOPLEFT", SCROLL_BOX_INSET, -SCROLL_BOX_INSET)
    box:SetPoint("BOTTOMRIGHT", -SCROLL_BOX_RIGHT_INSET, SCROLL_BOX_INSET)

    local bar = CreateFrame("EventFrame", nil, panel, "MinimalScrollBar")
    bar:SetPoint("TOPRIGHT", -SCROLL_BAR_INSET, -SCROLL_BAR_INSET)
    bar:SetPoint("BOTTOMRIGHT", -SCROLL_BAR_INSET, SCROLL_BAR_INSET)
    bar:SetHideIfUnscrollable(true)

    local view = CreateScrollBoxListTreeListView()
    view:SetPadding(LIST_PADDING, LIST_PADDING, LIST_PADDING, LIST_PADDING, LIST_SPACING)
    ScrollUtil.InitScrollBoxListWithScrollBar(box, bar, view)
    view:SetElementExtentCalculator(ns.Rows.GetExtent)
    view:SetElementFactory(ns.Rows.Factory)
    return box
end

-- The saved variables do not exist yet while this file loads, so the list is filled on first use.
local function EnsureContent()
    if contentBuilt then
        return
    end
    contentBuilt = true
    scrollBox:SetDataProvider(ns.SettingsPage.CreateDataProvider())
end

StyleWindow()
CreateCloseButton()
CreateVersionText()
CreatePortrait()
CreateTitle()
scrollBox = CreateContent()

local MainWindow = {}

function MainWindow.Toggle()
    EnsureContent()
    window:SetShown(not window:IsShown())
end

ns.MainWindow = MainWindow
