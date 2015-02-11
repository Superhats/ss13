-- class
local client = {}
client.__index = client

function client:new(server, peer, name)
    local new = setmetatable({}, self)

    new.server = server
    new.peer = peer
    new.name = name

    return new
end

function client:reset()
    self.peer:reset()
end

function client:disconnect(data)
    self.peer:disconnect_later(data)
end

function client:send(data, channel, mode)
    self.peer:send(mp.pack(data), channel, mode)
end

function client:on_connect()
    print(self.name .. " connected")

    -- Send world
    self:send({e = EVENT.WORLD_REPLACE, data = self.server.world:pack()})

    -- Utterly decimate them with entities
    for i, ent in pairs(self.server.entities) do
        self:send({
            e = EVENT.ENTITY_ADD,
            i = i,
            t = ent:get_type_id(),
            d = ent:pack()
        })
    end

    -- Try something
    self.player = self.server:add_entity(entities.player:new())
end

function client:on_disconnect()
    print(self.name .. " disconnected")

    self.player = self.server:remove_entity(self.player)

    if QUIT_ON_DISCONNECT then
        love.event.quit()
    end
end

function client:on_receive(data)
    print(self.name .. " sent " .. tostring(EVENT(data.e)))

    if data.e == EVENT.MOVE_TO then
        self.player.x = data.x * 32 + 16
        self.player.y = data.y * 32 + 16
        self.server:update_entity(self.player)
    end
end

return client
