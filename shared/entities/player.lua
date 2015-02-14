local class = require "../lib/class"

local player = {}
player.__index = player
setmetatable(player, entity)

local player_image = nil
local player_quads = nil

function player:new(game)
    if is_client and player_image == nil then
        player_image = love.graphics.newImage("assets/MobSpritesFull.png")
        player_quads = {
            forward = love.graphics.newQuad(0, 0, 32, 32, player_image:getDimensions())
        }
    end

    new = setmetatable({}, self)
    new.game = game
    new.x = 0
    new.y = 0
    new.ox = 0
    new.oy = 0
    return new
end

function player:pack()
    return {self.x, self.y}
end

function player:unpack(t)
    self.x = t[1]
    self.y = t[2]
end

function player:move(dx, dy)
    if self.move_dt then
        return false
    end

    local x = self.x + dx
    local y = self.y + dy

    if not self.game.world:is_solid(x, y) then
        self.ox, self.oy = self.x, self.y
        self.x, self.y = x, y
        self.move_dt = 0
        self.move_it = self:get_move_interval()

        if is_client then
            self.game:send{
                e = EVENT.MOVE_TO,
                x = dx,
                y = dy
            }
        end
    end

    return false
end

function player:get_move_interval()
    return 0.2
end

function player:update_camera(camera)
    camera:lookAt(self:get_lerp_pos())
    camera:zoomTo(1)
    camera:rotateTo(0)
end

function player:update(dt)
    if self.move_dt ~= nil then
        self.move_dt = self.move_dt + dt
        if self.move_dt >= self.move_it then
            self.move_dt = nil
        end
    end
end

local function lerp(t, a, b)
    return a + (b - a) * t
end

function player:get_true_pos()
    return
        (self.x + 0.5) * self.game.world.tile_size,
        (self.y + 0.5) * self.game.world.tile_size
end

function player:get_lerp_pos()
    local t = self.move_dt and (self.move_dt / self.move_it) or 1

    return
        lerp(t,
            (self.ox + 0.5) * self.game.world.tile_size,
            (self.x  + 0.5) * self.game.world.tile_size),
        lerp(t,
            (self.oy + 0.5) * self.game.world.tile_size,
            (self.y  + 0.5) * self.game.world.tile_size)
end

function player:draw()
    local x, y = self:get_lerp_pos()

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(player_image, player_quads.forward, x, y,
        0, 1, 1, 16, 16)
end

return player
