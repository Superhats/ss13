local enum = require "../lib/enum"

USE_LOVEBIRD = false
USE_LOGFILE = false
TRACE_NET = true

DEFAULT_PORT = 6788
NET_CHANNEL_COUNT = 8

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
    "UPDATE_FRAME",
    "WORLD_REPLACE",
    "WORLD_UPDATE",
    "ENTITY_ADD",
    "ENTITY_REMOVE",
    "ENTITY_UPDATE",
    "CONTROL_ENTITY",
    "MOVE_TO"
}

PACK_TYPE = enum {
    "INITIAL",
    "UPDATE_FRAME"
}
