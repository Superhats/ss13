local enum = require "../lib/enum"

USE_LOVEBIRD = true
USE_LOGFILE = true

NET_CHANNEL_COUNT = 4
PROTOCOL_VERSION = 0

DISCONNECT = enum {
    "INCOMPATIBLE",
    "NAME",
    "FULL",
    "EXITING"
}

EVENT = enum {
    "WORLD_REPLACE",
    "ENTITY_ADD",
    "ENTITY_REMOVE",
    "ENTITY_UPDATE",
    "MOVE_TO"
}

-- setmetatable(DISCONNECT, {
--     __call = function (i)
--         for k, v in pairs(DISCONNECT) do
--             if v == i then return k end
--         end
--     end
-- })
