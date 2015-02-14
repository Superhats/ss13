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
    local sound = love.audio.newSource("assets/port.mp3")
    --love.audio.play(sound)
    sound:setVolume(0.5)
    sound:play()

    debug_patch()
    local expect

    for i=2, #arg do
        if expect ~= nil then
            if expect == "--connect" then
                CONNECT_TO = arg[i]
            end
            expect = nil
        elseif arg[i] == "--connect" then
            expect = "--connect"
        else
            print("Unknown command line argument " .. arg[i])
            love.event.quit()
            return
        end
    end

    if expect ~= nil then
        print("Missing argument for " .. expect)
        love.event.quit()
        return
    end

    gamestate.registerEvents()

    if CONNECT_TO ~= nil then
        gamestate.switch(states.connecting, CONNECT_TO)
    else
        gamestate.switch(states.menu)
    end
end
