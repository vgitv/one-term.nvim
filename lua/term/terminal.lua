-- Terminal class-like table

local Terminal = {}

local utils = require "term.utils"

local terminal_instance

---Get or create new terminal instance (singleton design)
function Terminal:get_instance(opt)
    if not terminal_instance then
        local terminal = {
            options = opt, -- plugin options
            buf = -1, -- needs to be invalid at first hence -1
            win = -1, -- needs to be invalid at first hence -1
            height = nil, -- terminal window initial height
            width = nil,
            chan = nil, -- terminal window channel
            full_height = false, -- is terminal full height?
            layout = 1, -- default is the first enabled layout
        }

        self.__index = self
        terminal_instance = setmetatable(terminal, self)
    end
    return terminal_instance
end

---Create a new terminal instance or open the buffer in a new window if it already exists
---@param enter boolean Enter the window after it's creation
function Terminal:create_or_open(enter)
    if self.options.enabled_layouts[self.layout] == "vertical" then
        local height = math.floor(vim.o.lines * self.options.relative_height)
        local win_prop = utils.create_window_below { height = height, buf = self.buf, enter = enter }
        self.buf = win_prop.buf
        self.win = win_prop.win
        self.height = win_prop.height
    elseif self.options.enabled_layouts[self.layout] == "horizontal" then
        local width = math.floor(vim.o.columns * self.options.relative_width)
        local win_prop = utils.create_window_right { width = width, buf = self.buf, enter = enter }
        self.buf = win_prop.buf
        self.win = win_prop.win
        self.width = win_prop.width
    else
        print("ERROR, unknown layout " .. self.layout)
    end

    if vim.bo[self.buf].buftype ~= "terminal" then
        -- The options should be set first because the presence of 'number' may change the way
        -- the prompt is display (because it changes the terminal width)
        utils.set_local_options(self.win, self.options.local_options)
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
function Terminal:ensure_open()
    if not vim.api.nvim_win_is_valid(self.win) then
        self:create_or_open(false)
    end
end

---Execute script inside the terminal
---@param script string The script (could be multiline)
function Terminal:exec(script)
    vim.api.nvim_chan_send(self.chan, script .. "\x0d")
    utils.scroll_down(self.win)
end

function Terminal:set_layout(layout)
    if vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_hide(self.win)
    end
    self.layout = layout
    self:ensure_open()
end

return Terminal
