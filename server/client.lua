local class = require "../lib/class"
local client = class:extend()

local function name_used(game, name)
    for i, cl in ipairs(game.clients) do
        if cl.name == name then
            return true
        end
    end
    return false
end

function client:new(game, peer, name)
    local new = class.new(self)

    -- Fix up the name (testing)
    if name_used(game, name) then
        local i = 2
        while name_used(game, name .. i) do
            i = i + 1
        end
        name = name .. i
    end

    new.weak = setmetatable({}, {__mode = "kv"})
    new.game = game
    new.address = tostring(peer)
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
    if TRACE_NET and data.e ~= EVENT.UPDATE_FRAME then
        print("-> " .. self.name .. ": " .. tostring(EVENT(data.e)))
    end

    self.peer:send(mp.pack(data), channel, mode)
end

function client:get_control()
    return self.weak.control
end

function client:set_control(ent)
    if self.weak.control then
        self.weak.control.weak.controller = nil
        self.weak.control = nil
    end

    if ent then
        assert(ent.__id, "ent has no id")

        self.weak.control = ent
        ent.weak.controller = self

        self:send{e = EVENT.CONTROL_ENTITY, i = ent.__id}
    end
end

function client:on_connect()
    print(self.name .. " (" .. self.address .. ")" .. " connected")

    self:send{e = EVENT.HELLO}
    self:send{e = EVENT.WORLD_REPLACE, data = self.game.world:pack()}

    -- Send down all existing entities
    local data = {e = EVENT.ENTITY_ADD}
    local send

    for id, ent in pairs(self.game.entities) do
        data[id] = {ent:get_type_id(), ent:pack(PACK_TYPE.INITIAL)}
        send = true
    end

    if send then
        self:send(data)
    end

    -- Give them a player
    self.player = entities.player:new(self.game)
    self.player.pos = {16, 16}
    self:set_control(self.player)
end

function client:on_disconnect()
    print(self.name .. " (" .. self.address .. ")" .. " disconnected")

    self.player:remove()
    self.player = nil

    if QUIT_ON_DISCONNECT then
        -- love.event.quit()
    end
end

function client:on_receive(data)
    if TRACE_NET and data.e ~= EVENT.UPDATE_FRAME then
        print("<- " .. self.name .. ": " .. tostring(EVENT(data.e)))
    end

    if data.e == EVENT.UPDATE_FRAME then
        if self.weak.control then
            self.weak.control.input_state = data.i
        end
    end
end

return client
