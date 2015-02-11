local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)
    error_printer(tostring(msg), 2)

    while enable_console do
        love.timer.sleep(0.1)
        love.event.pump()
        for e, a, b, c in love.event.poll() do
            if e == "quit" then return end
        end
    end
end

require "../shared/const"

if USE_LOVEBIRD then
    lovebird = require "../lib/lovebird"
    lovebird.port = 8000
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

local server = require "server"

function love.load(arg)
    QUIT_ON_DISCONNECT = arg[2] == "--quit-on-disconnect"
    main = server:new()
    print("Server now running")
end

function love.quit()
    -- try our best to be graceful
    main:close(true)

    if USE_LOVEBIRD then lovebird.update() end
    if USE_LOGFILE  then logtick(1)        end
end

function love.update(dt)
    if USE_LOVEBIRD then lovebird.update() end
    if USE_LOGFILE  then logtick(dt)       end

    main:update(dt)
end
