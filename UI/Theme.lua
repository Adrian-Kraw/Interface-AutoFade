local _, ns = ...

local WHITE8X8 = "Interface\\BUTTONS\\WHITE8X8"
local FLAT_BACKDROP_EDGE_SIZE = 1

local FLAT_BACKDROP = {
    bgFile = WHITE8X8,
    edgeFile = WHITE8X8,
    edgeSize = FLAT_BACKDROP_EDGE_SIZE,
}

-- Same look as the settings window of Aklime Mod Tools.
local Theme = {
    COLORS = {
        WINDOW_BG = { r = 0.03, g = 0.03, b = 0.03, a = 0.95 },
        WINDOW_TEXTURE_TINT = { r = 0.114, g = 0.114, b = 0.114, a = 1 },
        WINDOW_BORDER = { r = 0.85, g = 0.68, b = 0.15, a = 0.9 },
        PANEL_BG = { r = 0.05, g = 0.05, b = 0.05, a = 0.85 },
        PANEL_BORDER = { r = 0.55, g = 0.45, b = 0.12, a = 0.9 },
        ACCENT = { r = 1.0, g = 0.82, b = 0.0, a = 1.0 },
        LINE = { r = 0.85, g = 0.68, b = 0.15, a = 0.6 },
        CLOSE_BUTTON = { r = 0.38, g = 0.06, b = 0.06, a = 0.95 },
        BUTTON_BG = { r = 0.05, g = 0.05, b = 0.05, a = 0.95 },
        BUTTON_BORDER = { r = 0.8, g = 0.65, b = 0.1, a = 1 },
    },
}

function Theme.ApplyFlatStyle(target, background, border)
    target:SetBackdrop(FLAT_BACKDROP)
    target:SetBackdropColor(background.r, background.g, background.b, background.a)
    target:SetBackdropBorderColor(border.r, border.g, border.b, border.a)
end

function Theme.SetTextureColor(texture, color)
    texture:SetColorTexture(color.r, color.g, color.b, color.a)
end

function Theme.SetTextColor(fontString, color)
    fontString:SetTextColor(color.r, color.g, color.b, color.a)
end

ns.Theme = Theme
