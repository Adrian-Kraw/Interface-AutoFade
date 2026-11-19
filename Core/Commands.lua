local _, ns = ...

local function HandleCommand()
    ns.MainWindow.Toggle()
end

local Commands = {}

-- Called from Main.lua once the database exists, so the handler never runs too early.
function Commands.Register()
    _G["SLASH_" .. ns.SLASH_KEY .. "1"] = ns.SLASH_COMMAND
    SlashCmdList[ns.SLASH_KEY] = HandleCommand
end

ns.Commands = Commands
