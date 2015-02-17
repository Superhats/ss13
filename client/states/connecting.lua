local connecting = {}
local address, host, peer, failed
local state, color

function connecting:enter(from, _address)
    address = _address

    if string.find(address, ":") == nil then
        address = address .. ":" .. DEFAULT_PORT
    end

    print("Connecting to " .. address)

    host = enet.host_create(nil, 1, NET_CHANNEL_COUNT, config.max_down, config.max_up)
    peer = host:connect(address)
    -- peer:ping_interval(200)

    failed = false

    state = "Connecting to " .. address
    color = {127, 127, 127}
end

function connecting:leave()
    address = nil
    host = nil
    peer = nil
end

function connecting:fail(error)
    if failed then
        return
    end

    failed = true
    state = "Error:\n" .. error
    color = {127, 95, 31}
end

function connecting:update(dt)
    if failed then
        return
    end

    local event = host:service(0)

    while event do
        if event.type == "receive" then
            local data = mp.unpack(event.data)

            if data.e == EVENT.HELLO then
                gamestate.switch(states.game, address, host, peer)
            else
                peer:disconnect_later(DISCONNECT.INVALID_PACKET)
            end

            break
        elseif event.type == "connect" then
            print("Connected to server")
            state = "Saying hello..."

            peer:send(mp.pack({
                name = config.name,
                version = PROTOCOL_VERSION
            }))
        elseif event.type == "disconnect" then
            local reason = DISCONNECT(event.data)
            reason = reason and " (" .. reason .. ")" or ""
            print("Disconnected from server" .. reason)
            if QUIT_ON_DISCONNECT then love.event.quit() end
            self:fail("Failed to connect to server" .. reason)
            break
        end

        event = host:service(0)
    end
end

function connecting:draw()
    local sw, sh = love.graphics.getDimensions()

    love.graphics.setColor(color)
    love.graphics.printf(state, 0, sh / 4, sw, "center")
end

return connecting
