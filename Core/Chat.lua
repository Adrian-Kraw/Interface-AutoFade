local _, ns = ...

local PREFIX_FORMAT = "|cff4fd1c5%s|r: %s"

local Chat = {}

function Chat.Print(message)
    print(string.format(PREFIX_FORMAT, ns.TEXT.TITLE, message))
end

ns.Chat = Chat
