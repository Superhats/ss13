local world_class = require "../shared/world"
local game = {is_client = true}

require("states/game/net")(game)
require("states/game/input")(game)

local camera = require("../shared/hump/camera")

function game:enter(previous, address, host, peer)
    self.address = address
    self.host = host
    self.peer = peer
    self.world = world_class:new()
    self.entities = {}
    self.control = setmetatable({}, {__mode = "kv"})
    self.camera = camera.new()

    self.sequence_client = -1
    self.sequence_client_ack = -1
    self.sequence_server = -1

    love.graphics.setColor(255, 255, 255)
    love.graphics.setBackgroundColor(0, 0, 0)

    self:init_input()
end

function game:leave()
    self.host = nil
    self.peer = nil
    self.world = nil
    self.entities = nil
end

function game:quit()
    self.peer:disconnect_later(DISCONNECT.EXITING)
    local event = self.host:service()

    while event do
        if event.type == "disconnect" then
            love.event.quit()
            break
        end

        event = self.host:service()
    end
end

function game:disconnect()
    self.peer:disconnect_later(DISCONNECT.EXITING)
end

function game:get_control()
    return self.control.ent
end

function game:update(dt)
    self:update_input(dt)
    self:update_net()

    self.world:update(dt)

    for id, ent in pairs(self.entities) do
        ent:update(dt)
    end

    local control = self:get_control()

    if control ~= nil then
        control:update_camera(self.camera)
    end
end

function game:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(
        "sequence_server = " .. self.sequence_server .. "\n" ..
        "sequence_client = " .. self.sequence_client .. "\n" ..
        "sequence_client_ack = " .. self.sequence_client_ack .. "\n" ..
        "ack_delta = " .. self.sequence_client - self.sequence_client_ack,
        8, 8, love.graphics.getWidth() - 16)

    self.camera:attach()
    self.world:draw()

    for id, ent in pairs(self.entities) do
        ent:draw()
    end

    self.camera:detach()
end

return game
