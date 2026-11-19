local _, ns = ...

-- Unnamed children of the minimap cluster (player arrow, quest blobs, merchant icons)
-- ignore the alpha of their parent. They are hidden instead, and a hook keeps them
-- hidden when Blizzard shows them again.
local isHidden = false
local hidMinimapDirectly = false
local minimapShowHooked = false
local hookedChildren = {}
local hiddenChildren = {}

-- In housing the minimap ignores the alpha of its cluster, so it is hidden itself.
-- The children stay untouched, because hiding them there would reflow the layout.
local function HideMinimapDirectly()
    if not minimapShowHooked then
        minimapShowHooked = true
        hooksecurefunc(Minimap, "Show", function(minimap)
            if isHidden and hidMinimapDirectly then
                minimap:Hide()
            end
        end)
    end
    hidMinimapDirectly = true
    Minimap:Hide()
end

local function HideUnnamedChildren()
    for _, child in ipairs({ MinimapCluster:GetChildren() }) do
        local name = child:GetName()
        if not name or name == "" then
            local ok, shown = pcall(child.IsShown, child)
            if ok and shown then
                if not hookedChildren[child] then
                    hookedChildren[child] = true
                    child:HookScript("OnShow", function(self)
                        if isHidden then
                            self:Hide()
                        end
                    end)
                end
                hiddenChildren[#hiddenChildren + 1] = child
                child:Hide()
            end
        end
    end
end

local MinimapOverlays = {}

function MinimapOverlays.Hide()
    if isHidden or not MinimapCluster then
        return
    end
    isHidden = true
    wipe(hiddenChildren)
    if Minimap and ns.Modes.IsHousingZone() then
        HideMinimapDirectly()
    else
        HideUnnamedChildren()
    end
end

function MinimapOverlays.Show()
    if not isHidden then
        return
    end
    isHidden = false
    if hidMinimapDirectly then
        hidMinimapDirectly = false
        Minimap:Show()
    end
    for _, child in ipairs(hiddenChildren) do
        pcall(child.Show, child)
    end
    wipe(hiddenChildren)
end

ns.MinimapOverlays = MinimapOverlays
