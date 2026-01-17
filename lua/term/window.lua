-- Window class-like table

---@class Window
---@field id integer Window id
local Window = {}

function Window:new()
    local window = {
        id = nil,
    }
    self.__index = self
    return setmetatable(window, self)
end

return Window
