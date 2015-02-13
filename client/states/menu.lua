local menu = {}
local address = "127.0.0.1:6788"

local menu_lib = require "../menu"
local menu_obj

function menu:init()
    local font = love.graphics.newFont(24)

    menu_obj = menu_lib:new(64, 64, font, {
        {label = "Connect to " .. address, func = function()
            gamestate.switch(states.connecting, address)
        end},
        {label = "Exit game", func = function() love.event.quit() end}
    }, 4, 40)
end

function menu:enter()
    menu_obj.index = 1

    -- love.graphics.setLineWidth(2)
    love.graphics.setBackgroundColor(60, 70, 70)
end

function menu:keypressed(key, code)
    if key == "down" then
        menu_obj:next()
    elseif key == "up" then
        menu_obj:previous()
    end
end

function menu:keyreleased(key, code)
    if key == "return" then
        menu_obj:activate()
    end
end

function menu:mousepressed(x, y, button)
    menu_obj:mousepressed(x, y, button)
end

function menu:update(dt)
    menu_obj:update(dt)
end

function menu:draw()
    menu_obj:draw()
    -- local text = "Connect to " .. address
    -- local height = love.graphics.getFont():getHeight(text)
    -- local x, y = 48, 48
    --
    -- love.graphics.setColor(255, 200, 127)
    -- love.graphics.rectangle("line", x - 12 - 3, y + height/2 - 3, 6, 6)
    -- love.graphics.setColor(255, 255, 255)
    -- love.graphics.print(text, x, y)
end

-- function menu:keyreleased(key, code)
--     if key == "return" then
--         gamestate.switch(states.connecting, address)
--     end
-- end

return menu
