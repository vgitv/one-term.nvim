local M = {}
M.Terminal = {}

local utils = require "utils"

local terminal_instance

---Get or create new terminal instance (singleton design)
function M.Terminal:get_instance()
    if not terminal_instance then
        local terminal = {}

        terminal.buf = -1 -- needs to be invalid at first hence -1
        terminal.win = -1 -- needs to be invalid at first hence -1
        terminal.height = nil -- terminal window initial height
        terminal.chan = nil -- terminal window channel
        terminal.full_height = false -- is terminal full height?

        self.__index = self
        terminal_instance = setmetatable(terminal, self)
    end
    return terminal_instance
end

---Create a new terminal instance or open the buffer in a new window if it already exists
---@param relative_height number Relative height of the future window
---@param local_options table Local options to apply to the term buffer
---@param enter boolean Enter the window after it's creation
function M.Terminal:create_or_open(relative_height, local_options, enter)
    local height = math.floor(vim.o.lines * relative_height)
    local win_prop = utils.create_window_below { height = height, buf = self.buf, enter = enter }
    self.buf = win_prop.buf
    self.win = win_prop.win
    self.height = win_prop.height

    if vim.bo[self.buf].buftype ~= "terminal" then
        -- The options should be set first because the presence of 'number' may change the way
        -- the prompt is display (because it changes the terminal width)
        utils.set_local_options(self.win, local_options)
        vim.api.nvim_set_option_value("winhighlight", "Normal:MainTerminalNormal", { win = self.win })
        -- Create terminal instance after setting local options
        vim.api.nvim_buf_call(self.buf, vim.cmd.terminal)
        -- setting the buflisted option needs to be after calling terminal command
        vim.api.nvim_set_option_value("buflisted", false, { buf = self.buf })
    end

    self.chan = vim.bo[self.buf].channel
    self.full_height = false
end

---When it's needed to have a terminal window opened but without entering the terminal window
---@param relative_height number Relative height of the future window
---@param local_options table Local options to apply to the term buffer
function M.Terminal:ensure_open(relative_height, local_options)
    if not vim.api.nvim_win_is_valid(self.win) then
        self:create_or_open(relative_height, local_options, false)
    end
end

return M
