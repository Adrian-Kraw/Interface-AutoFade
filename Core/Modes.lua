local _, ns = ...

local CLIENT = ns.CLIENT
local MODE = ns.MODE
local EXCLUDE = ns.EXCLUDE

local ALL_CLIENTS = { CLIENT.RETAIL, CLIENT.FOREVER }
-- Forever has no player housing, so the housing mode only exists in Retail.
local RETAIL_ONLY = { CLIENT.RETAIL }

-- The fade code itself lives in Modules\HUDFader_Retail.lua and Modules\HUDFader_Forever.lua.
-- dbKey is the key in the saved variables. apiSuffix ends the method names of those files,
-- for example SetEnabled2 for the second mode.
-- extraExcludes lists elements that only exist in this mode and can be kept visible there.
local DEFINITIONS = {
    { key = MODE.CHILL, dbKey = "mode1", apiSuffix = "", clients = ALL_CLIENTS },
    { key = MODE.OPEN_WORLD, dbKey = "mode2", apiSuffix = "2", clients = ALL_CLIENTS },
    {
        key = MODE.HOUSING, dbKey = "mode3", apiSuffix = "3", clients = RETAIL_ONLY,
        extraExcludes = { EXCLUDE.HOUSING_MENU },
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

ns.Modes = Modes
