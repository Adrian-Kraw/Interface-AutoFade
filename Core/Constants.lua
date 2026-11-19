local addonName, ns = ...

ns.ADDON_NAME = addonName
ns.ICON_TEXTURE = "Interface\\AddOns\\" .. addonName .. "\\Assets\\icon"

-- Client keys. Client.lua decides which one is active.
ns.CLIENT = {
    RETAIL = "retail",
    FOREVER = "forever",
}

-- Mode keys are also the keys in the saved variables.
ns.MODE = {
    CHILL = "chill",
    OPEN_WORLD = "openworld",
    HOUSING = "housing",
}

-- Blizzard uses these instance types for player housing.
ns.INSTANCE_TYPE = {
    NEIGHBORHOOD = "neighborhood",
    INTERIOR = "interior",
}

-- Element groups a player can keep visible while the rest fades.
ns.EXCLUDE = {
    CHAT = "chat",
    MINIMAP = "minimap",
    OBJECTIVES = "objectives",
    MICRO_MENU = "microMenu",
    BAGS = "bags",
    ACTION_BARS = "actionBars",
    UNIT_FRAMES = "unitFrames",
    BUFFS = "buffs",
    REP_BAR = "repBar",
    DAMAGE_METER = "damageMeter",
}

-- Order of the toggles in the settings window.
ns.EXCLUDE_ORDER = {
    ns.EXCLUDE.CHAT,
    ns.EXCLUDE.MINIMAP,
    ns.EXCLUDE.OBJECTIVES,
    ns.EXCLUDE.MICRO_MENU,
    ns.EXCLUDE.BAGS,
    ns.EXCLUDE.ACTION_BARS,
    ns.EXCLUDE.UNIT_FRAMES,
    ns.EXCLUDE.BUFFS,
    ns.EXCLUDE.REP_BAR,
    ns.EXCLUDE.DAMAGE_METER,
}

-- Names of the values stored per mode.
ns.SETTING = {
    ENABLED = "enabled",
    ALPHA = "alpha",
    MOVE_DELAY = "moveDelay",
    IDLE_DELAY = "idleDelay",
    CHAT_DELAY = "chatDelay",
}

ns.DEFAULTS = {
    ENABLED = false,
    ALPHA_PERCENT = 60,
    MOVE_DELAY = 1,
    IDLE_DELAY = 5,
    CHAT_DELAY = 5,
    MINIMAP_ANGLE = 220,
}

ns.LIMITS = {
    ALPHA = { MIN = 0, MAX = 100 },
    MOVE_DELAY = { MIN = 0, MAX = 10 },
    IDLE_DELAY = { MIN = 5, MAX = 60 },
    CHAT_DELAY = { MIN = 5, MAX = 60 },
}

ns.ALPHA = {
    HIDDEN = 0,
    FULL = 1,
}

ns.PERCENT = 100

-- Alpha units per second. A full fade takes a little under one second.
ns.FADE_SPEED = 1.5

-- Pause after a loading screen before the interface fades out.
ns.ENTERING_WORLD_DELAY = 2

ns.SLASH_KEY = "INTERFACEAUTOFADE"
ns.SLASH_COMMAND = "/autofade"

ns.TEMPLATE = {
    HEADER = "InterfaceAutoFade_ModuleHeaderTemplate",
    TOGGLE = "InterfaceAutoFade_ToggleTemplate",
    SLIDER = "InterfaceAutoFade_SliderTemplate",
    INFO = "InterfaceAutoFade_InfoTextTemplate",
    SEPARATOR = "InterfaceAutoFade_SeparatorTemplate",
}

-- Row heights of the settings list in pixels.
ns.ROW_EXTENT = {
    [ns.TEMPLATE.HEADER] = 32,
    [ns.TEMPLATE.TOGGLE] = 32,
    [ns.TEMPLATE.SLIDER] = 52,
    [ns.TEMPLATE.INFO] = 24,
    [ns.TEMPLATE.SEPARATOR] = 50,
}

ns.TEXT = {
    TITLE = "Interface AutoFade",
    UNSUPPORTED_CLIENT = "This game client is not supported. Supported clients are Retail and Forever.",
    SECTION_FADING = "Interface Fading",
    SLIDER_TRANSPARENCY = "Transparency",
    SLIDER_MOVE_DELAY = "Move Duration until Fade In",
    SLIDER_IDLE_DELAY = "Fade Out After",
    SLIDER_CHAT_DELAY = "Chat Visible For",
    INSTANT = "instant",
    PERCENT_FORMAT = "%d%%",
    SECONDS_FORMAT = "%d s",
    ALWAYS_VISIBLE = "Always visible at 100%:",
    MINIMAP_CLICK = "Click: Open / close settings",
    MINIMAP_DRAG = "Drag: Change position",
    CLOSE = "X",
    MODE_LABEL = {
        [ns.MODE.CHILL] = "Chill Mode in Rest Areas",
        [ns.MODE.OPEN_WORLD] = "Open World",
        [ns.MODE.HOUSING] = "Housing",
    },
    EXCLUDE_LABEL = {
        [ns.EXCLUDE.CHAT] = "Chat",
        [ns.EXCLUDE.MINIMAP] = "Minimap",
        [ns.EXCLUDE.OBJECTIVES] = "Quest / Objectives",
        [ns.EXCLUDE.MICRO_MENU] = "Micro Menu",
        [ns.EXCLUDE.BAGS] = "Bags",
        [ns.EXCLUDE.ACTION_BARS] = "Action Bars",
        [ns.EXCLUDE.UNIT_FRAMES] = "Unit Frames",
        [ns.EXCLUDE.BUFFS] = "Buffs / Debuffs",
        [ns.EXCLUDE.REP_BAR] = "Reputation Bar",
        [ns.EXCLUDE.DAMAGE_METER] = "Damage Meter",
    },
}
