return function(game)
    function game:send(data, channel, mode)
        self.peer:send(mp.pack(data), channel, mode)
    end

    function game:update_net()
        -- so our goal is to handle events & send one packet with our input
        -- each frame of the game
        self.sequence_client = self.sequence_client + 1

        self:send({
            e = EVENT.UPDATE_FRAME,
            s = self.sequence_client,
            i = self:get_input_state()
        })

        local event = self.host:service()

        while event do
            if event.type == "receive" then
                local data = mp.unpack(event.data)

                if TRACE_NET then
                    print("Server sent " .. tostring(EVENT(data.e)))
                end

                if data.e == EVENT.WORLD_REPLACE then
                    self.world:unpack(data.data)
                elseif data.e == EVENT.UPDATE_FRAME then
                    self.sequence_server = data.s
                    self.sequence_client_ack = data.a
                    data.e = nil
                    data.s = nil
                    data.a = nil
                    for id, t in pairs(data) do
                        self.entities[id]:unpack(t)
                    end
                elseif data.e == EVENT.WORLD_UPDATE then
                    self.world:set(data.x, data.y, data.i)
                elseif data.e == EVENT.ENTITY_ADD then
                    local type = entity_from_id(data.t)
                    local ent = type:new(self, data.i)
                    -- local ent = type:new(self)
                    -- self.entities[data.i] = ent
                    -- ent.__id = data.i
                    ent:unpack(data.d, true)
                elseif data.e == EVENT.ENTITY_REMOVE then
                    self.entities[data.i] = nil
                elseif data.e == EVENT.ENTITY_UPDATE then
                    self.entities[data.i]:unpack(data.d)
                elseif data.e == EVENT.CONTROL_ENTITY then
                    self.control.ent = self.entities[data.i]
                end
            elseif event.type == "disconnect" then
                local reason = DISCONNECT(event.data)
                reason = reason and " (" .. reason .. ")" or ""
                print("Disconnected from server" .. reason)

                if CONNECT_TO ~= nil then
                    love.event.quit()
                else
                    gamestate.switch(states.menu)
                end
                -- need to do something here
                -- display a message box that leads to menu upon pressing enter?
            end

            event = self.host:service()
        end
    end
end
