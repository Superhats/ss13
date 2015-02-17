-- class
local client = {}
client.__index = client

function client:new(game, peer, name)
    local new = setmetatable({}, self)

    new.game = game
    new.address = tostring(peer)
    new.peer = peer
    new.name = name
    new.__control = setmetatable({}, {__mode = "kv"})

    new.sequence_client = -1
    new.sequence_server = -1

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
    return self.__control.ent
end

function client:set_control(ent)
    assert(ent.__id ~= nil, "ent has no id")

    ent.__control.client = self
    self.__control.ent = ent

    self:send{e = EVENT.CONTROL_ENTITY, i = ent.__id}
end

function client:on_connect()
    print(self.name .. " (" .. self.address .. ")" .. " connected")

    self:send{e = EVENT.HELLO}
    self:send{e = EVENT.WORLD_REPLACE, data = self.game.world:pack()}

    -- Utterly decimate them with entities
    for i, ent in pairs(self.game.entities) do
        self:send{
            e = EVENT.ENTITY_ADD,
            i = i,
            t = ent:get_type_id(),
            d = ent:pack()
        }
    end

    -- Try something
    self.player = entities.player:new(self.game)
    self.player.x = 16
    self.player.y = 16
    self:set_control(self.player)
end

function client:on_disconnect()
    print(self.name .. " (" .. self.address .. ")" .. " disconnected")

    self.player = self.game:remove_entity(self.player)

    if QUIT_ON_DISCONNECT then
        love.event.quit()
    end
end

function client:on_receive(data)
    if TRACE_NET then
        print(self.name .. " sent " .. tostring(EVENT(data.e)))
    end

    if data.e == EVENT.UPDATE_FRAME then
        self.sequence_client = data.s
        self.last_input_state = data.i
    end
end

return client
