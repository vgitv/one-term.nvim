-- Window class-like table

---@class Window
---@field id integer Window id
local Window = {}

function Window:new()
    local window = {
        id = nil,
    }
    setmetatable(window, self)
    self.__index = self
    return window
end

return Window
