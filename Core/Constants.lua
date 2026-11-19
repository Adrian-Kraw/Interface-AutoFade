local _, ns = ...

-- Client keys. Client.lua decides which one is active.
ns.CLIENT = {
    RETAIL = "retail",
    FOREVER = "forever",
}

-- Mode keys are lowercase because they are typed in the slash command.
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

ns.ALPHA = {
    MIN = 0,
    MAX = 1,
    DEFAULT_FADED = 0.3,
}

ns.PERCENT = 100

ns.SLASH_KEY = "INTERFACEAUTOFADE"
ns.SLASH_COMMAND = "/autofade"

ns.TEXT = {
    TITLE = "Interface AutoFade",
    UNSUPPORTED_CLIENT = "This game client is not supported. Supported clients are Retail and Forever.",
    STATUS_HEADER = "Client: %s, active mode: %s",
    NO_ACTIVE_MODE = "none",
    MODE_STATUS = "%s: %s, alpha %.0f%%",
    ENABLED = "enabled",
    DISABLED = "disabled",
    USAGE = "Usage: /autofade [status | enable <mode> | disable <mode> | alpha <mode> <percent>]",
    UNKNOWN_MODE = "Mode '%s' is not available in this client. Available modes: %s",
    INVALID_ALPHA = "Alpha must be a number between 0 and 100.",
    MODE_LABEL = {
        [ns.MODE.CHILL] = "Chill (rest areas)",
        [ns.MODE.OPEN_WORLD] = "Open world",
        [ns.MODE.HOUSING] = "Housing",
    },
}
