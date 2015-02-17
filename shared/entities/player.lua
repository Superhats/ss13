local player = entity:extend()

local player_image = nil
local player_quads = nil

function player:__init()
    if self.is_ghost and player_image == nil then
        player_image = love.graphics.newImage("assets/MobSpritesFull.png")
        player_quads = {
            forward = love.graphics.newQuad(0, 0, 32, 32, player_image:getDimensions())
        }
    end

    self.x = 0
    self.y = 0

    return self
end

function player:pack()
    return {self.x, self.y}
end

function player:unpack(t)
    self.x = t[1]
    self.y = t[2]
end

function player:update_camera(camera)
    camera:lookAt(math.floor(self.x + 0.5), math.floor(self.y + 0.5))
    camera:zoomTo(1)
    camera:rotateTo(0)
end

function player:update(dt)
    if not self.is_ghost then
        local input = self:get_input()

        if input ~= nil then
            self.x = self.x + input[1] * 32 * dt
            self.y = self.y + input[2] * 32 * dt
        end
    end
end

function player:draw()
    local x = math.floor(self.x + 0.5)
    local y = math.floor(self.y + 0.5)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(player_image, player_quads.forward, x, y,
        0, 1, 1, 16, 16)
end

return player
