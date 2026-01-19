-- Window class-like table

local utils = require "utils"

---@class Window
---@field buf integer Buffer id
---@field id integer Window id
---@field config table Window config
local Window = {}

---Window constructor
---@param buf integer Buffer id
function Window:new(buf)
    local window = {
        buf = utils.get_buf(buf),
        id = nil,
        config = nil,
    }
    setmetatable(window, self)
    self.__index = self
    return window
end

---Open the window
---@param enter boolean Enter the window or not
function Window:open(enter)
    enter = enter or false
    self.id = vim.api.nvim_open_win(self.buf, enter, self.config)
end

return Window
