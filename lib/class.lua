local class = {}
class.__index = class

function class:new(t)
    return setmetatable(t or {}, self)
end

function class:extend(t)
    local new = setmetatable(t or {}, self)
    new.__index = new
    return new
end

return class
