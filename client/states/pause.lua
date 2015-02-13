local pause = {}

local menu = {
    {label = "Resume", func = function()
        gamestate.pop()
    end},
    {label = "Disconnect from server", func = function(self)
        self.previous:disconnect()
    end},
    {label = "Exit game", func = function(self)
        self.previous:quit()
    end}
}

function pause:init()
    self.font_label = love.graphics.newFont(18)
    self.font_stats = love.graphics.newFont(12)
end

function pause:enter(previous)
    self.index = 1
    self.previous = previous
end

function pause:keypressed(key, code)
    if key == "down" then
        if self.index == #menu then
            self.index = 1
        else
            self.index = self.index + 1
        end
    elseif key == "up" then
        if self.index == 1 then
            self.index = #menu
        else
            self.index = self.index - 1
        end
    end
end

function pause:keyreleased(key, code)
    if key == "escape" then
        gamestate.pop()
    elseif key == "return" then
        menu[self.index].func(self)
    end
end

function pause:update(dt)
    self.previous:update(dt)
end

function pause:draw()
    self.previous:draw()

    love.graphics.setFont(self.font_label)
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())

    for i, entry in ipairs(menu) do
        if i == self.index then
            love.graphics.setColor(0, 0, 0, 75)
            love.graphics.rectangle("fill", 60, 60 + i * 30,
                self.font_label:getWidth(entry.label) + 8,
                self.font_label:getHeight(entry.label) + 8)
            love.graphics.setColor(255, 255, 255)
        else
            love.graphics.setColor(255, 255, 255, 200)
        end

        love.graphics.print(entry.label, 64, 64 + i * 30)
    end

    -- Draw stats in top right
    love.graphics.setFont(self.font_stats)
    love.graphics.setColor(255, 255, 255, 150)

    love.graphics.printf(
        "Game version: v" .. GAME_VERSION .. "\n" ..
        "Frame time: " .. math.ceil(love.timer.getDelta() * 1000) .. "\n" ..
        "Ping: " .. self.previous.peer:round_trip_time() .. "ms\n" ..
        "Server: " .. self.previous.address,
        0, 8, love.graphics.getWidth() - 8, "right")
end

return pause
