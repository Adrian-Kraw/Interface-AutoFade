local _, ns = ...

if GetLocale() ~= "deDE" then
    return
end

local TEXT = ns.TEXT

TEXT.UNSUPPORTED_CLIENT = "Dieser Spielclient wird nicht unterstützt. Unterstützt werden Retail und Forever."
TEXT.SECTION_FADING = "Interface Ausblendung"
TEXT.SLIDER_TRANSPARENCY = "Transparenz"
TEXT.SLIDER_MOVE_DELAY = "Bewegdauer bis Einblenden"
TEXT.SLIDER_IDLE_DELAY = "Ausblenden nach"
TEXT.SLIDER_CHAT_DELAY = "Chat eingeblendet für"
TEXT.TOGGLE_HOVER_REVEAL = "Beim Hovern einblenden"
TEXT.INSTANT = "sofort"
TEXT.ALWAYS_VISIBLE = "Immer bei 100% sichtbar:"
TEXT.MINIMAP_CLICK = "Klick: Einstellungen öffnen/schließen"
TEXT.MINIMAP_DRAG = "Ziehen: Position ändern"

TEXT.MODE_LABEL[ns.MODE.CHILL] = "Chillmodus in Ruhezonen"
TEXT.MODE_LABEL[ns.MODE.OPEN_WORLD] = "Offene Welt"

TEXT.EXCLUDE_LABEL[ns.EXCLUDE.OBJECTIVES] = "Quest / Ziele"
TEXT.EXCLUDE_LABEL[ns.EXCLUDE.MICRO_MENU] = "Mikromenü"
TEXT.EXCLUDE_LABEL[ns.EXCLUDE.BAGS] = "Taschen"
TEXT.EXCLUDE_LABEL[ns.EXCLUDE.ACTION_BARS] = "Aktionsleisten"
TEXT.EXCLUDE_LABEL[ns.EXCLUDE.UNIT_FRAMES] = "HP-Anzeigen"
TEXT.EXCLUDE_LABEL[ns.EXCLUDE.REP_BAR] = "Rufbar"
TEXT.EXCLUDE_LABEL[ns.EXCLUDE.DAMAGE_METER] = "Schadensanzeige"
TEXT.EXCLUDE_LABEL[ns.EXCLUDE.HOUSING_MENU] = "Housing-Baumenü"
