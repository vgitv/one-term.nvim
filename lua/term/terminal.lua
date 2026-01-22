-- Terminal class-like table

---@class Terminal
---@field options table Plugin options
---@field buf integer Terminal buffer id
---@field win integer Terminal window id
---@field chan integer Terminal window channel
---@field fullscreen_win integer
---@field layout integer Layout id
---@field height integer Terminal height
---@field width integer Terminal width
local Terminal = {}

local utils = require "term.utils"
local Window = require "term.window"

local terminal_instance

---Get or create new terminal instance (singleton design)
function Terminal:get_instance(opt)
    if not terminal_instance then
        local default_layout = opt.enabled_layouts[1]

        terminal_instance = {
            options = opt, -- plugin options
            buf = -1, -- needs to be invalid at first hence -1
            win = -1, -- needs to be invalid at first hence -1
            chan = nil, -- terminal window channel
            fullscreen_win = -1,
            layout = 1, -- default is the first enabled layout
            layout_name = default_layout,
            height = math.floor(vim.o.lines * (opt[default_layout].relative_height or 0)),
            width = math.floor(vim.o.lines * (opt[default_layout].relative_width or 0)),
            windows = {},
            current_window = nil,
        }

        for i, l in ipairs(opt.enabled_layouts) do
            if l == "vertical" then
                terminal_instance[i] = Window:new {
                    split = "below",
                    win = -1,
                    height = math.floor(vim.o.lines * (opt.vertical.relative_height or 0)),
                }
            elseif l == "horizontal" then
                terminal_instance[i] = Window:new {
                    split = "right",
                    win = -1,
                    width = math.floor(vim.o.lines * (opt.horizontal.relative_width or 0)),
                }
            elseif l == "floating" then
                local height = math.floor(vim.o.lines * (opt.floating.relative_height or 0))
                local width = math.floor(vim.o.lines * (opt.floating.relative_width or 0))
                terminal_instance[i] = Window:new {
                    relative = "editor",
                    height = height,
                    width = width,
                    col = math.floor((vim.o.columns - width) / 2),
                    row = math.floor((vim.o.lines - height) / 2),
                    style = "minimal",
                    border = "none",
                }
            else
                print("Error - unknown layout " .. l)
            end
        end

        terminal_instance.current_window = terminal_instance.windows[1]

        setmetatable(terminal_instance, self)
        self.__index = self
    end
    return terminal_instance
end

---Create a new terminal instance or open the buffer in a new window if it already exists
---@param enter boolean Enter the window after it's creation
function Terminal:create_or_open(enter)
    self.buf, self.win = utils.create_window[self.layout_name] {
        height = self.height,
        width = self.width,
        buf = self.buf,
        enter = enter,
    }

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
end

---When it's needed to have a terminal window opened
function Terminal:ensure_open()
    local enter
    -- Enter term window only for floating layout because it makes no sense to keep the cursor in the background window
    if self.layout_name == "floating" then
        enter = true
    else
        enter = false
    end
    if not vim.api.nvim_win_is_valid(self.win) then
        self:create_or_open(enter)
    end
end

-- TODO: make the return optional and use this method in the clear / kill commands
---Execute script inside the terminal
---@param script string The script (could be multiline)
function Terminal:exec(script)
    vim.api.nvim_chan_send(self.chan, script .. "\x0d")
    utils.scroll_down(self.win)
end

function Terminal:hide()
    if vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_hide(self.win)
    end
end

---Set the layout given it's index
---@param layout integer layout index from the enabled_layouts table
function Terminal:set_layout(layout)
    if layout > #self.options.enabled_layouts then
        print "ERROR - Invalid layout range"
        return
    end

    self:hide()
    self.layout = layout
    self.layout_name = self.options.enabled_layouts[layout]

    -- When switching layout, size from the previous layout will not be remembered
    self.height = math.floor(vim.o.lines * (self.options[self.layout_name].relative_height or 0))
    self.width = math.floor(vim.o.columns * (self.options[self.layout_name].relative_width or 0))

    self:ensure_open()
end

---Is the terminal fullscreen?
---@return boolean
function Terminal:is_fullscreen()
    -- Because window ids are uniq accross nvim session, this is a way to know if fullscreen mode is on or off, whether
    -- the floating window was closed using the toggle_fullscreen function or with a quit command.
    return vim.api.nvim_win_is_valid(self.fullscreen_win)
end

---Activate fullscreen mode
function Terminal:fullscreen_mode()
    self:hide()
    self.buf, self.win = utils.create_window["floating"] {
        height = vim.o.lines,
        width = vim.o.columns,
        buf = self.buf,
        enter = true,
        border = "none",
    }
    -- HACK: if the floating window is closed using :q instead of calling the toggle_fullscreen
    self.fullscreen_win = self.win
end

return Terminal
