local menu_lib = require "../menu"
local pause = {}

local menu

function pause:init()
    self.font_label = love.graphics.newFont(24)
    self.font_stats = love.graphics.newFont(10)

    menu = menu_lib:new(64, 64, self.font_label, {
        {label = "Resume", func = function()
            gamestate.pop()
        end},
        {label = "Disconnect from server", func = function()
            self.previous:disconnect()
        end, disabled = CONNECT_TO ~= nil},
        {label = "Exit game", func = function()
            self.previous:quit()
        end}
    }, 4, 40)
end

function pause:enter(previous)
    menu.index = 1
    self.previous = previous
end

function pause:keypressed(key, code)
    if key == "down" then
        menu:next()
    elseif key == "up" then
        menu:previous()
    end
end

function pause:keyreleased(key, code)
    if key == "escape" then
        gamestate.pop()
    elseif key == "return" then
        menu:activate()
    end
end

function pause:mousepressed(x, y, button)
    menu:mousepressed(x, y, button)
end

function pause:update(dt)
    self.previous:update(dt)
    menu:update(dt)
end

function pause:draw()
    self.previous:draw()

    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())

    menu:draw()

    -- Draw stats in top right
    love.graphics.setFont(self.font_stats)
    love.graphics.setColor(255, 255, 255, 150)

    love.graphics.printf(
        "Game version: v" .. GAME_VERSION .. "\n" ..
        "Frame time: " .. math.ceil(love.timer.getDelta() * 1000000) .. "us\n" ..
        "Ping: " .. self.previous.peer:round_trip_time() .. "ms\n" ..
        "Server: " .. self.previous.address,
        0, 8, love.graphics.getWidth() - 8, "right")
end

return pause
