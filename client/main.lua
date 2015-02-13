require "enet"
mp = require "../lib/msgpack"

require "../shared/const"
require "../shared/debug"
require "../shared/entities"

gamestate = require "../shared/hump/gamestate"

states = {
    menu = require "states/menu",
    connecting = require "states/connecting",
    game = require "states/game",
    pause = require "states/pause"
}

function love.load()
    debug_patch()
    QUIT_ON_DISCONNECT = arg[2] == "--quit-on-disconnect"

    gamestate.registerEvents()
    gamestate.switch(states.menu)
end
