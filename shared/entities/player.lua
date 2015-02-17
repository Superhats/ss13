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

    self.pos = {0, 0}
end

function player:pack()
    return self.pos
end

function player:unpack(t)
    self.pos = t
end

function player:update_camera(camera)
    camera:lookAt(
        math.floor(self.pos[1] + 0.5),
        math.floor(self.pos[2] + 0.5))
    camera:zoomTo(1)
    camera:rotateTo(0)
end

function player:update(dt)
    if not self.is_ghost then
        if self.input_state then
            self.pos[1] = self.pos[1] + self.input_state[1] * 32 * dt
            self.pos[2] = self.pos[2] + self.input_state[2] * 32 * dt
        end
    end
end

function player:draw()
    local x = math.floor(self.pos[1] + 0.5)
    local y = math.floor(self.pos[2] + 0.5)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(player_image, player_quads.forward, x, y,
        0, 1, 1, 16, 16)
end

return player
