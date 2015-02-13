local connecting = {}
local address, host, server, error, failed

function connecting:enter(from, _address)
    address = _address
    print("Connecting to " .. address)

    host = enet.host_create(nil, 1, NET_CHANNEL_COUNT, config.max_down, config.max_up)
    server = host:connect(address)

    error = nil
    failed = false
end

function connecting:leave()
    address = nil
    host = nil
    server = nil
end

function connecting:update(dt)
    if failed or error ~= nil then
        return
    end

    local event = host:service(0)

    while event do
        if event.type == "receive" then
            local data = mp.unpack(event.data)

            if data.e == EVENT.HELLO then
                gamestate.switch(states.game, address, host, server)
            else
                server:disconnect_later(DISCONNECT.INVALID_PACKET)
                failed = true
            end

            break
        elseif event.type == "connect" then
            print("Connected to server")

            server:send(mp.pack({
                name = config.name,
                version = PROTOCOL_VERSION
            }))
        elseif event.type == "disconnect" then
            local reason = DISCONNECT(event.data)
            reason = reason and " (" .. reason .. ")" or ""
            print("Disconnected from server" .. reason)
            if QUIT_ON_DISCONNECT then love.event.quit() end
            error = "Failed to connect to server" .. reason
            break
        end

        event = host:service(0)
    end
end

function connecting:draw()
    local sw, sh = love.graphics.getDimensions()

    if error ~= nil then
        love.graphics.setColor(127, 31, 0, 255)
        love.graphics.printf("Error:\n" .. error, 0, sh / 4, sw, "center")
    else
        love.graphics.setColor(127, 127, 127, 255)
        love.graphics.printf("Connecting to server", 0, sh / 4, sw, "center")
    end
end

return connecting
