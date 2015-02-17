return function(game)
    function game:send(data, channel, mode)
        if TRACE_NET and data.e ~= EVENT.UPDATE_FRAME then
            print("-> server: " .. tostring(EVENT(data.e)))
        end

        self.peer:send(mp.pack(data), channel, mode)
    end

    function game:update_net()
        self:send({
            e = EVENT.UPDATE_FRAME,
            i = self:get_input_state()
        }, 0, "unreliable")

        local event = self.host:service()

        while event do
            if event.type == "receive" then
                local data = mp.unpack(event.data)

                if TRACE_NET and data.e ~= EVENT.UPDATE_FRAME then
                    print("<- server: " .. tostring(EVENT(data.e)))
                end

                local event = data.e
                data.e = nil

                if event == EVENT.WORLD_REPLACE then
                    self.world:unpack(data.data)
                elseif event == EVENT.UPDATE_FRAME then
                    for id, t in pairs(data) do
                        if self.entities[id] == nil then
                            if TRACE_NET then
                                error("got update for unknown ghost " .. id)
                            end
                        else
                            self.entities[id]:unpack(t)
                        end
                    end
                elseif event == EVENT.WORLD_UPDATE then
                    self.world:set(data.x, data.y, data.i)
                elseif event == EVENT.ENTITY_ADD then
                    for id, entry in pairs(data) do
                        local type = entity_from_id(entry[1])
                        local ent = type:new(self, id)
                        ent:unpack(entry[2], true)
                    end
                elseif event == EVENT.ENTITY_REMOVE then
                    for i, id in data do
                        self.entities[id] = nil
                    end
                elseif event == EVENT.CONTROL_ENTITY then
                    self.control_id = data.i
                else
                    print("Unhandled event from server " .. tostring(event) .. tostring(EVENT(event)))
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
