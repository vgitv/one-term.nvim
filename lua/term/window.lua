-- Window class-like table

local utils = require "term.utils"

---@class Window
---@field buf integer Buffer id
---@field id integer Window id
---@field config table Window config
local Window = {}

---Window constructor
function Window:new(config)
    local window = {
        config = config,
        id = nil,
    }
    setmetatable(window, self)
    self.__index = self
    return window
end

---Open the window
---@param opts table Enter the window or not
function Window:open(opts)
    opts = opts or {}

    local enter = opts.enter or false
    local buf = utils.get_buf(opts.buf)

    self.id = vim.api.nvim_open_win(buf, enter, self.config)

    return buf
end

return Window
