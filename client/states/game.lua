local world_class = require "../shared/world"

local game = {}
local host, server, game_world, game_entities

function game:enter(previous, _host, _server)
    host, server = _host, _server
    game_world = world_class:new()
    game_entities = {}

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBackgroundColor(255, 255, 255, 255)
end

function game:leave()
    host = nil
    server = nil
    game_world = nil
    game_entities = nil
end

function game:disconnect()
    server:disconnect_later(DISCONNECT.EXITING)
end

function game:update(dt)
    local event = host:service()

    while event do
        if event.type == "receive" then
            local data = mp.unpack(event.data)
            print("Got packet " .. tostring(EVENT(data.e)))

            if data.e == EVENT.WORLD_REPLACE then
                game_world:unpack(data.data)
            elseif data.e == EVENT.ENTITY_ADD then
                local type = entity_from_id(data.t)
                local ent = type:new()
                game_entities[data.i] = ent
                ent.__id = data.i
                ent:unpack(data.d)
            elseif data.e == EVENT.ENTITY_REMOVE then
                game_entities[data.i] = nil
            elseif data.e == EVENT.ENTITY_UPDATE then
                game_entities[data.i]:unpack(data.d)
            end
        elseif event.type == "disconnect" then
            local reason = DISCONNECT(event.data)
            reason = reason and " (" .. reason .. ")" or ""
            print("Disconnected from server" .. reason)
            if QUIT_ON_DISCONNECT then love.event.quit() end
            -- need to do something here
            -- display a message box that leads to menu upon pressing enter?
        end

        event = host:service()
    end

    game_world:update(dt)

    for id, ent in pairs(game_entities) do
        ent:update(dt)
    end
end

function game:mousepressed(x, y, button)
    if button == "l" then
        server:send(mp.pack({
            e = EVENT.MOVE_TO,
            x = math.floor(x / 32),
            y = math.floor(y / 32)
        }))
    end
end

function game:draw()
    game_world:draw()

    for id, ent in pairs(game_entities) do
        ent:draw()
    end
end

return game
