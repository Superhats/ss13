local client = require "client"
local world = require "../shared/world"

local MAX_PEERS = 64
local MAX_DOWN = 0
local MAX_UP = 0

local server = {}
server.__index = server

function server:new()
    local new = setmetatable({}, self)
    local address = (config.public and "localhost" or "*") .. ":" .. config.port

    new.host = enet.host_create(address, config.max_peers,
        4, config.max_down, config.max_up)

    if new.host ~= nil then
        print("Listening on " .. address)
    else
        error("Cannot bind to " .. address)
    end

    new.world = world:new(new)
    new.time = 0

    new.clients  = {}
    new.entities = {}
    new.next_id  = 0

    return new
end

function server:close(from_quit)
    for i=1, self.host:peer_count() do
        self.host:get_peer(i):disconnect(DISCONNECT.EXITING)
    end

    self.host:service(0)
    self.host = nil

    collectgarbage() -- probably not necessary

    -- should be removed for multiserver support
    if not from_quit then
        love.event.quit()
    end
end

function server:send(data, channel, mode)
    data = mp.pack(data)

    for i, cl in ipairs(self.clients) do
        cl.peer:send(data, channel, mode)
    end
end

function server:add_entity(ent)
    ent.__id = self.next_id

    self.entities[self.next_id] = ent
    self.next_id = self.next_id + 1

    self:send({
        e = EVENT.ENTITY_ADD,
        i = ent.__id,
        t = ent:get_type_id(),
        d = ent:pack()
    })

    return ent
end

function server:remove_entity(ent)
    assert(ent.__id ~= nil, "entity has no id")

    self:send({e = EVENT.ENTITY_REMOVE, i = ent.__id})
    self.entities[ent.__id] = nil

    ent.__id = nil
    return nil
end

function server:update_entity(ent)
    self:send({
        e = EVENT.ENTITY_UPDATE,
        i = ent.__id,
        d = ent:pack()
    })
end

function server:update(dt)
    self.time = self.time + dt
    self:update_net()

    self.world:update(dt)

    for id, ent in pairs(self.entities) do
        ent:update(dt)
    end
end

function server:update_net()
    local event = self.host:service(0)

    while event do
        local peer = event.peer

        if event.type == "connect" then
            -- don't care for now
            -- maybe log it later
            -- should time out connections that don't send handshake
        elseif event.type == "disconnect" then
            local cl = self.clients[peer:index()]

            if cl ~= nil then
                cl:on_disconnect()
                self.clients[peer:index()] = nil
            end
        elseif event.type == "receive" then
            local data = mp.unpack(event.data)
            local cl = self.clients[peer:index()]

            if cl == nil then
                if data.version ~= PROTOCOL_VERSION then
                    peer:disconnect_later(DISCONNECT.INCOMPATIBLE)
                elseif data.name == "" then
                    peer:disconnect_later(DISCONNECT.NAME)
                else
                    cl = client:new(self, peer, data.name)
                    self.clients[peer:index()] = cl
                    cl:on_connect()
                end
            else
                cl:on_receive(data)
            end
        end

        event = self.host:service(0)
    end
end

return server
