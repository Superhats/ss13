if USE_LOVEBIRD then
    lovebird = require "../lib/lovebird"
    -- local port
    -- if is_client then
    --     math.randomseed(os.clock())
    --     port = math.random(8001, 9000)
    -- else
    --     port = config.port
    -- end
    -- lovebird.port = port
    -- print("lovebird port = " .. port)
    lovebird.port = is_client and 8001 or 8000
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

function debug_patch()
    local quit = love.quit
    function love.quit()
        if quit then quit() end
        if USE_LOVEBIRD then lovebird.update() end
        if USE_LOGFILE  then logtick(1)        end
    end

    local update = love.update
    function love.update(dt)
        if USE_LOVEBIRD then lovebird.update() end
        if USE_LOGFILE  then logtick(dt)       end
        if update then update(dt) end
    end
end
