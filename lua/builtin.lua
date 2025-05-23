-- Here are defined the builtin subcommands

local M = {}
M.subcommands = {}

local utils = require "utils"
local config = require "config"

-- terminal state
local state = {
    buf = -1, -- needs to be invalid at first hence -1
    win = -1, -- needs to be invalid at first hence -1
    height = nil, -- terminal window initial height
    chan = nil, -- terminal window channel
    full_height = false, -- is terminal full height?
}

---Split current window
---@param relative_height number Relative height of the future window
M.subcommands.toggle_window = function(relative_height)
    relative_height = relative_height or config.options.relative_height
    if not vim.api.nvim_win_is_valid(state.win) then
        utils.create_or_open_terminal(state, relative_height, config.options.local_options, true)
        if config.options.startinsert then
            vim.cmd.startinsert()
        end
    else
        vim.api.nvim_win_hide(state.win)
    end
end

---Make the terminal window full height
M.subcommands.toggle_fullheight = function()
    if vim.api.nvim_win_is_valid(state.win) then
        if state.full_height then
            vim.api.nvim_win_set_height(state.win, state.height)
            state.full_height = false
        else
            vim.api.nvim_win_set_height(state.win, vim.o.lines)
            state.full_height = true
        end
    else
        print "The terminal window must be open to run this command"
    end
end

---Send line under cursor into the terminal
M.subcommands.send_current_line = function()
    utils.ensure_open_terminal(state, config.options.relative_height, config.options.local_options)
    local current_line = vim.api.nvim_get_current_line()
    -- trim line
    local exec_line = current_line:gsub("^%s+", ""):gsub("%s+$", "")
    if exec_line == "" then
        return
    end
    vim.api.nvim_chan_send(state.chan, exec_line .. "\x0d")

    utils.scroll_down(state.win)
end

---Send visually selected lines to the terminal
M.subcommands.send_visual_lines = function()
    utils.ensure_open_terminal(state, config.options.relative_height, config.options.local_options)
    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    for _, line in ipairs(lines) do
        local exec_line = line:gsub("^%s+", ""):gsub("%s+$", "")
        -- It is important here to dont skip blank lines for languages that use indentation to spot end of function
        -- / loop etc. (like python). And it should be a blank line after each end of function / loop etc.
        vim.api.nvim_chan_send(state.chan, exec_line .. "\x0d")
    end

    utils.scroll_down(state.win)
end

---Send visual selection
M.subcommands.send_visual_selection = function()
    utils.ensure_open_terminal(state, config.options.relative_height, config.options.local_options)
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_row, start_col = unpack(start_pos, 2, 3)
    local end_row, end_col = unpack(end_pos, 2, 3)
    -- Why -1? Because the doc says:
    -- Indexing is zero-based. Row indices are end-inclusive, and column indices are end-exclusive.
    local text = vim.api.nvim_buf_get_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, {})
    for _, line in ipairs(text) do
        local exec_line = line:gsub("^%s+", ""):gsub("%s+$", "")
        -- It is important here to dont skip blank lines for languages that use indentation to spot end of function
        -- / loop etc. (like python). And it should be a blank line after each end of function / loop etc.
        vim.api.nvim_chan_send(state.chan, exec_line .. "\x0d")
    end

    utils.scroll_down(state.win)
end

---Jump to error location
M.subcommands.jump = function()
    if vim.api.nvim_get_current_win() == state.win then
        local current_line = vim.api.nvim_get_current_line()
        local filepath = nil
        local linenumber = nil
        for _, pattern in pairs(config.options.errorformat) do
            filepath, linenumber = string.match(current_line, pattern)
            if filepath and linenumber then
                break
            end
        end
        if (not filepath) or not linenumber then
            print "Unable to find file path and line number from pattern list"
            return
        end
        -- Go to previously accessed window
        vim.cmd.wincmd "p"
        vim.cmd("edit " .. filepath)
        vim.cmd("normal! " .. linenumber .. "G_")
    else
        print "You must be inside the terminal window to run this command"
    end
end

---Run previous command without leaving buffer
M.subcommands.run_previous = function()
    if not vim.api.nvim_buf_is_valid(state.buf) then
        -- If the main terminal doesnt exist, the previous command has good chances to be a nvim command!
        -- This will prevent from accidentally opening a new neovim instance inside the terminal buffer.
        print "You need to create a terminal buffer first"
        return
    end

    utils.ensure_open_terminal(state, config.options.relative_height, config.options.local_options)

    -- Send Ctrl-p signal to the terminal followed by carriage return
    vim.api.nvim_chan_send(state.chan, "\x10\x0d")

    utils.scroll_down(state.win)
end

---Clear terminal
M.subcommands.clear = function()
    if vim.api.nvim_win_is_valid(state.win) then
        -- Send Ctrl-l signal to the terminal
        vim.api.nvim_chan_send(state.chan, "\x0c")
    else
        print "The terminal window must be open to run this command"
    end
end

---Kill currently running command
M.subcommands.kill = function()
    if vim.api.nvim_win_is_valid(state.win) then
        -- Send Ctrl-c signal to the terminal
        vim.api.nvim_chan_send(state.chan, "\x03")
    else
        print "The terminal window must be open to run this command"
    end
end

---Exit terminal
M.subcommands.exit = function()
    if vim.api.nvim_buf_is_valid(state.buf) then
        -- Send Ctrl-d signal to the terminal
        vim.api.nvim_chan_send(state.chan, "\x04")
        print "Terminal successfully exited"
    else
        print "No terminal to exit"
    end
end

---Resize terminal window
---@param mouvement string Mouvement for window resizing like +5 or -2 for instance
M.subcommands.resize = function(mouvement)
    if vim.api.nvim_win_is_valid(state.win) then
        local current_height = vim.api.nvim_win_get_height(state.win)
        local height
        if string.match(mouvement, "^+[0-9]+$") then
            height = current_height + tonumber(string.sub(mouvement, 2))
        elseif string.match(mouvement, "^-[0-9]+$") then
            height = current_height - tonumber(string.sub(mouvement, 2))
        else
            print "ERROR - Invalid argument"
            return
        end
        vim.api.nvim_win_set_height(state.win, height)
    else
        print "The terminal window must be open to run this command"
    end
end

---Run arbitrary command
---@param ... any Command line
M.subcommands.run = function(...)
    local cmd = table.concat({ ... }, " ")
    utils.ensure_open_terminal(state, config.options.relative_height, config.options.local_options)
    vim.api.nvim_chan_send(state.chan, cmd .. "\x0d")
    utils.scroll_down(state.win)
end

return M
