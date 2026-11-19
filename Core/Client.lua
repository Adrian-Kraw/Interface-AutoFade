local _, ns = ...

local CLIENT = ns.CLIENT

-- Other Forever addons use this interface range as well.
local FOREVER_INTERFACE_MIN = 16001
local FOREVER_INTERFACE_MAX = 19999

local function GetInterfaceVersion()
    return select(4, GetBuildInfo())
end

-- Forever has its own project id. The interface range is the fallback in case the
-- constant is missing. Forever is checked first because a Forever client may also
-- report the mainline project id.
local function IsForever()
    if WOW_PROJECT_CAMELOT and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT then
        return true
    end
    local interfaceVersion = GetInterfaceVersion()
    return interfaceVersion >= FOREVER_INTERFACE_MIN and interfaceVersion <= FOREVER_INTERFACE_MAX
end

local function DetectClient()
    if IsForever() then
        return CLIENT.FOREVER
    end
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return CLIENT.RETAIL
    end
    return nil
end

local Client = {
    current = DetectClient(),
}

function Client.IsSupported()
    return Client.current ~= nil
end

ns.Client = Client
