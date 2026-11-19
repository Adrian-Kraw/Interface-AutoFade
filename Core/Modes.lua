local _, ns = ...

local CLIENT = ns.CLIENT
local MODE = ns.MODE
local INSTANCE_TYPE = ns.INSTANCE_TYPE

local ALL_CLIENTS = { CLIENT.RETAIL, CLIENT.FOREVER }
-- Forever has no player housing, so the housing mode only exists in Retail.
local RETAIL_ONLY = { CLIENT.RETAIL }

local function IsOutsideInstance()
    return not IsInInstance()
end

local function IsInHousing()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == INSTANCE_TYPE.NEIGHBORHOOD or instanceType == INSTANCE_TYPE.INTERIOR)
end

-- The modes exclude each other, so at most one of them is active at a time.
local DEFINITIONS = {
    {
        key = MODE.CHILL,
        clients = ALL_CLIENTS,
        isActive = function()
            return IsResting() and IsOutsideInstance()
        end,
    },
    {
        key = MODE.OPEN_WORLD,
        clients = ALL_CLIENTS,
        isActive = function()
            return not IsResting() and IsOutsideInstance()
        end,
    },
    {
        key = MODE.HOUSING,
        clients = RETAIL_ONLY,
        isActive = IsInHousing,
    },
}

local function SupportsClient(definition, clientKey)
    for _, supportedClient in ipairs(definition.clients) do
        if supportedClient == clientKey then
            return true
        end
    end
    return false
end

local function BuildAvailableModes()
    local available = {}
    for _, definition in ipairs(DEFINITIONS) do
        if SupportsClient(definition, ns.Client.current) then
            available[#available + 1] = definition
        end
    end
    return available
end

-- The client never changes while the game runs, so this list is built once.
local availableModes = BuildAvailableModes()

local Modes = {}

function Modes.GetAvailable()
    return availableModes
end

function Modes.Find(modeKey)
    for _, mode in ipairs(availableModes) do
        if mode.key == modeKey then
            return mode
        end
    end
    return nil
end

function Modes.GetActive()
    for _, mode in ipairs(availableModes) do
        if mode.isActive() then
            return mode
        end
    end
    return nil
end

ns.Modes = Modes
