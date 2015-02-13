return function (game)
    function game:keyreleased(key, code)
        if key == "escape" then
            gamestate.push(states.pause)
        end
    end

    function game:mousepressed(x, y, button)
        if button == "l" then
            self.peer:send(mp.pack({
                e = EVENT.MOVE_TO,
                x = math.floor(x / 32),
                y = math.floor(y / 32)
            }))
        end
    end
end
