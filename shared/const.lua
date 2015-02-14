local enum = require "../lib/enum"

USE_LOVEBIRD = true
USE_LOGFILE = false
TRACE_NET = false

DEFAULT_PORT = 6788
NET_CHANNEL_COUNT = 4

GAME_VERSION = "0.0.0"
PROTOCOL_VERSION = 0

DISCONNECT = enum {
    "INCOMPATIBLE",
    "NAME",
    "FULL",
    "EXITING",
    "INVALID_PACKET"
}

EVENT = enum {
    "HELLO",
    "WORLD_REPLACE",
    "WORLD_UPDATE",
    "ENTITY_ADD",
    "ENTITY_REMOVE",
    "ENTITY_UPDATE",
    "CONTROL_ENTITY",
    "MOVE_TO"
}
