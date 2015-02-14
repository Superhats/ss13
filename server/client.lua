-- class
local client = {}
client.__index = client

function client:new(server, peer, name)
    local new = setmetatable({}, self)

    new.server = server
    new.address = tostring(peer)
    new.peer = peer
    new.name = name
    new.control = setmetatable({}, {__mode = "kv"})

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

function client:get_control()
    return self.control.ent
end

function client:set_control(ent)
    assert(ent.__id ~= nil, "ent has no id")
    self.control.ent = ent
    self:send({e = EVENT.CONTROL_ENTITY, i = ent.__id})
end

function client:on_connect()
    print(self.name .. " (" .. self.address .. ")" .. " connected")

    self:send({e = EVENT.HELLO})
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
    self:set_control(self.player)
end

function client:on_disconnect()
    print(self.name .. " (" .. self.address .. ")" .. " disconnected")

    self.player = self.server:remove_entity(self.player)

    if QUIT_ON_DISCONNECT then
        love.event.quit()
    end
end

function client:on_receive(data)
    if TRACE_NET then
        print(self.name .. " sent " .. tostring(EVENT(data.e)))
    end

    if data.e == EVENT.MOVE_TO then
        local control = self:get_control()
        control.x = data.x * 32 + 16
        control.y = data.y * 32 + 16
        self.server:update_entity(control)
    end
end

return client
