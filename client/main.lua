if true then
    lovebird = require "../lib/lovebird"
    lovebird.port = 8001
    lovebird.update()
end

require "../shared/const"

if false then
    lovebird = require "../lib/lovebird"
    lovebird.port = 8001
    lovebird.update()
end

if USE_LOGFILE then
    local logfile = assert(love.filesystem.newFile("out.log", "w"))
    local logdirt = false
    local logtime = 0

    local print_func = print
    function print(...)
        print_func(...)
        local args = {...}
        for i, value in ipairs(args) do
            args[i] = tostring(value)
        end
        logfile:write(table.concat(args, "    ") .. "\r\n")
        logdirt = true
    end

    function logtick(dt)
        if logdirt then
            logtime = logtime + dt
            if logtime >= 1 then
                logtime = logtime - 1
                logdirt = false
                logfile:flush()
            end
        end
    end
end

require "enet"
mp = require "../lib/msgpack"

require "../shared/entities"

local world = require "../shared/world"

function love.load()
    QUIT_ON_DISCONNECT = arg[2] == "--quit-on-disconnect"

    host = enet.host_create(nil, 1, NET_CHANNEL_COUNT,
        config.max_down, config.max_up)

    server = host:connect(config.server)
    remote_world = world:new()
    remote_entities = {}
end

function love.quit()
    server:disconnect_now(DISCONNECT.EXITING)

    if USE_LOVEBIRD then lovebird.update() end
    if USE_LOGFILE  then logtick(1)        end
end

function love.update(dt)
    if USE_LOVEBIRD then lovebird.update() end
    if USE_LOGFILE  then logtick(dt)       end

    local event = host:service()

    while event do
        if event.type == "receive" then
            local data = mp.unpack(event.data)
            print("Got packet " .. tostring(EVENT(data.e)))

            if data.e == EVENT.WORLD_REPLACE then
                remote_world:unpack(data.data)
            elseif data.e == EVENT.ENTITY_ADD then
                local type = entity_from_id(data.t)
                local ent = type:new()
                remote_entities[data.i] = ent
                ent.__id = data.i
                ent:unpack(data.d)
            elseif data.e == EVENT.ENTITY_REMOVE then
                remote_entities[data.i] = nil
            elseif data.e == EVENT.ENTITY_UPDATE then
                remote_entities[data.i]:unpack(data.d)
            end
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
        end

        event = host:service()
    end
end

function love.mousepressed(x, y, button)
    if button == "l" then
        server:send(mp.pack({
            e = EVENT.MOVE_TO,
            x = math.floor(x / 32),
            y = math.floor(y / 32)
        }))
    end
end

function love.draw()
    remote_world:draw()

    for id, ent in pairs(remote_entities) do
        ent:draw()
    end
end
