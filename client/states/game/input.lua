return function (game)
    local keymap = {
        left = "left",
        right = "right",
        up = "up",
        down = "down",
        a = "left",
        d = "right",
        w = "up",
        s = "down"
    }

    local deltas = {
        left = {-1, 0},
        right = {1, 0},
        up = {0, -1},
        down = {0, 1}
    }

    local move_rate = 0.175

    function game:mousepressed(x, y, button)
        x, y = self.camera:worldCoords(x, y)

        self.peer:send(mp.pack({
            e = EVENT.INTERACT_XY,
            x = math.floor(x / 32),
            y = math.floor(y / 32),
            b = button
        }))
    end

    function game:keypressed(key, code)
        if keymap[key] ~= nil then
            self:keyreleased(key, code)
            table.insert(self.input_stack, keymap[key])
        end
    end

    function game:keyreleased(key, code)
        if key == "escape" then
            gamestate.push(states.pause)
        elseif keymap[key] ~= nil then
            for i, value in ipairs(self.input_stack) do
                if value == keymap[key] then
                    table.remove(self.input_stack, i)
                    break
                end
            end
        end
    end

    local t = 0

    function game:init_input()
        self.input_stack = {}
        t = 0
    end

    function game:update_input(dt)
        if gamestate.current() ~= self then
            return
        end

        if #self.input_stack > 0 then
            local control = self:get_control()
            local delta = deltas[self.input_stack[#self.input_stack]]
            control:move(unpack(delta))
        end

        -- if t == 0 then
        --     if #self.input_stack > 0 then
        --         local delta = deltas[self.input_stack[#self.input_stack]]
        --         local control = self:get_control()
        --
        --         local x = math.floor(control.x / 32 + delta[1])
        --         local y = math.floor(control.y / 32 + delta[2])
        --
        --         if not self.world:is_solid(x, y) then
        --             self.peer:send(mp.pack({
        --                 e = EVENT.MOVE_TO,
        --                 x = x,
        --                 y = y
        --             }))
        --             t = dt
        --         end
        --     end
        -- elseif t < move_rate then
        --     t = t + dt
        -- else
        --     t = 0
        -- end
    end
end
