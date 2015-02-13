local world_class = require "../shared/world"
local game = {}

require("states/game/input")(game)

function game:enter(previous, host, peer)
    self.host = host
    self.peer = peer
    self.world = world_class:new()
    self.entities = {}

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBackgroundColor(255, 255, 255, 255)
end

function game:leave()
    self.host = nil
    self.peer = nil
    self.world = nil
    self.entities = nil
end

function game:disconnect()
    self.peer:disconnect_later(DISCONNECT.EXITING)
end

function game:update(dt)
    local event = self.host:service()

    while event do
        if event.type == "receive" then
            local data = mp.unpack(event.data)
            print("Got packet " .. tostring(EVENT(data.e)))

            if data.e == EVENT.WORLD_REPLACE then
                self.world:unpack(data.data)
            elseif data.e == EVENT.ENTITY_ADD then
                local type = entity_from_id(data.t)
                local ent = type:new()
                self.entities[data.i] = ent
                ent.__id = data.i
                ent:unpack(data.d)
            elseif data.e == EVENT.ENTITY_REMOVE then
                self.entities[data.i] = nil
            elseif data.e == EVENT.ENTITY_UPDATE then
                self.entities[data.i]:unpack(data.d)
            end
        elseif event.type == "disconnect" then
            local reason = DISCONNECT(event.data)
            reason = reason and " (" .. reason .. ")" or ""
            print("Disconnected from server" .. reason)
            if QUIT_ON_DISCONNECT then love.event.quit() end
            -- need to do something here
            -- display a message box that leads to menu upon pressing enter?
        end

        event = self.host:service()
    end

    self.world:update(dt)

    for id, ent in pairs(self.entities) do
        ent:update(dt)
    end
end

function game:draw()
    self.world:draw()

    for id, ent in pairs(self.entities) do
        ent:draw()
    end
end

return game
