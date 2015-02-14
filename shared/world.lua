local world = {}
world.__index = world

function world:new(server)
    local new = setmetatable({}, self)

    new.server = server
    new.tile_size = 32
    new.width = 0
    new.height = 0
    new.data = {}

    if is_client then
        new.image = love.graphics.newImage("assets/tileset.png")
        new.quads = {}

        local width, height = new.image:getDimensions()

        for i=1, (width / new.tile_size) * (height / new.tile_size) do
            local x = math.floor((i-1) % (width / new.tile_size)) * new.tile_size
            local y = math.floor((i-1) / (width / new.tile_size)) * new.tile_size
            table.insert(new.quads, love.graphics.newQuad(
                x, y, new.tile_size, new.tile_size, width, height))
            print("world_tile", i, x, y)
        end
    else
        -- extreme cheating
        new.data = {
            {1, 1, 2, 2, 3, 3, 4, 4},
            {1, 1, 2, 2, 3, 3, 4, 4},
            {2, 2, 3, 3, 4, 4, 1, 1},
            {2, 2, 3, 3, 4, 4, 1, 1},
        }

        new.width = #new.data[1]
        new.height = #new.data
    end

    return new
end

function world:pack()
    return self.data
end

function world:unpack(t)
    self.width = #t[1]
    self.height = #t
    self.data = t
end

function world:get(x, y)
    if x < 0 or y < 0 or x >= self.width or y >= self.height then
        return nil
    end
    return self.data[y+1][x+1]
end

function world:set(x, y, i)
    if x >= 0 and y >= 0 and x < self.width and y < self.height then
        self.data[x+1][y+1] = i

        if self.server ~= nil then
            self.server:send({
                e = EVENT.WORLD_UPDATE,
                x = x,
                y = y,
                i = i
            })
        end
    end
end

function world:is_solid(x, y)
    return self:get(x, y) == nil
end

function world:update(dt)
end

function world:draw()
    love.graphics.setColor(255, 255, 255)

    for x=0, self.width-1 do
        for y=0, self.height-1 do
            love.graphics.draw(self.image,
                self.quads[self:get(x, y)],
                x*self.tile_size, y*self.tile_size)
        end
    end
end

return world
