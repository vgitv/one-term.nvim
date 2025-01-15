-- Here are defined the :Terminal builtin subcommands:
-- :Terminal <builtin-subcommand>

local M = {}
M.subcommands = {}


local utils = require('utils')

-- plugin options
local options = {}

-- terminal state
local state = {
    buf = -1,  -- needs to be invalid at first hence -1
    win = -1,  -- needs to be invalid at first hence -1
    height = nil,
    chan = nil,
}

-- is the terminal full height?
local full_height = false


M.setup_options = function(opts)
    options = opts or {}
end


---Split current window
---@param relative_height number Relative height of the future window
M.subcommands.toggle_window = function(relative_height)
    relative_height = relative_height or options.relative_height
    if not vim.api.nvim_win_is_valid(state.win) then
        state = utils.create_or_open_terminal(relative_height, true, state.buf, options.local_options)
        if options.startinsert then
            vim.cmd.startinsert()
        end
    else
        vim.api.nvim_win_hide(state.win)
    end
end


---Make the terminal window full height
M.subcommands.toggle_fullheight = function()
    if vim.api.nvim_win_is_valid(state.win) then
        if full_height then
            vim.api.nvim_win_set_height(state.win, state.height)
            full_height = false
        else
            vim.api.nvim_win_set_height(state.win, vim.o.lines)
            full_height = true
        end
    else
        print('The terminal window must be open to run this command')
    end
end


-- Send line under cursor into the terminal
M.subcommands.send_current_line = function()
    state = utils.ensure_open_terminal(options.relative_height, state, options.local_options)
    local current_line = vim.api.nvim_get_current_line()
    -- trim line
    local exec_line = current_line:gsub('^%s+', ''):gsub('%s+$', '')
    if exec_line == '' then
        return
    end
    vim.api.nvim_chan_send(state.chan, exec_line .. '\x0d')

    utils.scroll_down(state.win)
end


---Send visually selected lines to the terminal
M.subcommands.send_visual_lines = function()
    state = utils.ensure_open_terminal(options.relative_height, state, options.local_options)
    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]
    print(start_line, end_line)
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    for _, line in ipairs(lines) do
        local exec_line = line:gsub('^%s+', ''):gsub('%s+$', '')
        -- It is important here to dont skip blank lines for languages that use indentation to spot end of function
        -- / loop etc. (like python). And it should be a blank line after each end of function / loop etc.
        vim.api.nvim_chan_send(state.chan, exec_line .. '\x0d')
    end

    utils.scroll_down(state.win)
end


---Jump to file X line Y from stacktrace
M.subcommands.jump = function()
    if vim.api.nvim_get_current_win() == state.win then
        local current_line = vim.api.nvim_get_current_line()
        local filepath = nil
        local linenumber = nil
        for _, pattern in pairs(options.stacktrace_patterns) do
            filepath, linenumber = string.match(current_line, pattern)
            if filepath and linenumber then
                break
            end
        end
        if (not filepath) or (not linenumber) then
            print('Unable to find file path and line number from pattern list')
            return
        end
        -- Go to previously accessed window
        vim.cmd.wincmd('p')
        vim.cmd('edit ' .. filepath)
        vim.cmd('normal! ' .. linenumber .. 'G_')
    else
        print('You must be inside the terminal window to run this command')
    end
end


---Run previous command without leaving buffer
M.subcommands.run_previous = function()
    if not vim.api.nvim_buf_is_valid(state.buf) then
        -- If the main terminal doesnt exist, the previous command has good chances to be a nvim command!
        -- This will prevent from accidentally opening a new neovim instance inside the terminal buffer.
        print('You need to create a terminal buffer first')
        return
    end

    state = utils.ensure_open_terminal(options.relative_height, state, options.local_options)

    -- Send Ctrl-p signal to the terminal followed by carriage return
    vim.api.nvim_chan_send(state.chan, '\x10\x0d')

    utils.scroll_down(state.win)
end


---Clear terminal
M.subcommands.clear = function()
    if vim.api.nvim_win_is_valid(state.win) then
        -- Send Ctrl-l signal to the terminal
        vim.api.nvim_chan_send(state.chan, '\x0c')
    else
        print('The terminal window must be open to run this command')
    end
end

---Kill currently running command
M.subcommands.kill = function()
    if vim.api.nvim_win_is_valid(state.win) then
        -- Send Ctrl-c signal to the terminal
        vim.api.nvim_chan_send(state.chan, '\x03')
    else
        print('The terminal window must be open to run this command')
    end
end


---Exit terminal
M.subcommands.exit = function()
    if vim.api.nvim_buf_is_valid(state.buf) then
        -- Send Ctrl-d signal to the terminal
        vim.api.nvim_chan_send(state.chan, '\x04')
        print('Terminal successfully exited')
    else
        print('No terminal to exit')
    end
end


---Resize terminal window
---@param mouvement string Mouvement for window resizing like +5 or -2 for instance
M.subcommands.resize = function(mouvement)
    if vim.api.nvim_win_is_valid(state.win) then
        local current_height = vim.api.nvim_win_get_height(state.win)
        local height
        if string.match(mouvement, '^+[0-9]+$') then
            height = current_height + tonumber(string.sub(mouvement, 2))
        elseif string.match(mouvement, '^-[0-9]+$') then
            height = current_height - tonumber(string.sub(mouvement, 2))
        else
            print('ERROR - Invalid argument')
            return
        end
        vim.api.nvim_win_set_height(state.win, height)
    else
        print('The terminal window must be open to run this command')
    end
end


return M
