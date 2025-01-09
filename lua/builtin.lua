-- Here are defined the :Terminal builtin subcommands:
-- :Terminal <builtin-subcommand>

local M = {}
M.subcommands = {}


local utils = require('utils')

-- plugin options
local options = {}

-- terminal state
local state = {
    buf = -1,
    win = -1,
    height = -1,
}

-- is the terminal full height?
local full_height = false

-- regex patterns to go to file x line y using stacktrace
local stacktrace_patterns = {
    '([^ ]*):([0-9]):', -- lua
    '^ *File "(.*)", line ([0-9]+)',  -- python
    '^(.*): line ([0-9]+)',  -- bash
}


M.setup_options = function(opts)
    options = opts or {}
end


-- split current window
M.subcommands.toggle_window = function(relative_height)
    relative_height = relative_height or options.relative_height
    local height = math.floor(vim.o.lines * relative_height)
    if not vim.api.nvim_win_is_valid(state.win) then
        state = utils.create_window_below { height = height, buf = state.buf }
        if vim.bo[state.buf].buftype ~= 'terminal' then
            -- The options should be set first because the presence of 'number' may change the way
            -- the prompt is display (becaus it changes the terminal width)
            utils.set_local_options(options.local_options)
            vim.bo.buflisted = false
            vim.opt_local.winhighlight = 'Normal:MainTerminalNormal'
            -- Create terminal instance after setting local options
            vim.cmd.terminal()
        end
        if options.startinsert then
            vim.cmd.startinsert()
        end
    else
        vim.api.nvim_win_hide(state.win)
    end
end


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
        print('Open a terminal first')
    end
end


M.subcommands.send_current_line = function()
    if vim.api.nvim_buf_is_valid(state.buf) then
        local current_line = vim.api.nvim_get_current_line()
        -- trim line
        local exec_line = current_line:gsub('^%s+', ''):gsub('%s+$', '')
        if exec_line == '' then
            return
        end
        local term_chan = vim.api.nvim_buf_get_var(state.buf, 'terminal_job_id')
        vim.api.nvim_chan_send(term_chan, exec_line .. "\n")
        if vim.api.nvim_win_is_valid(state.win) then
            local current_win = vim.api.nvim_get_current_win()
            vim.api.nvim_set_current_win(state.win)
            vim.cmd("normal! G")
            vim.api.nvim_set_current_win(current_win)
        end
    else
        print('Open a terminal first')
    end
end


M.subcommands.send_visual_lines = function()
    if vim.api.nvim_buf_is_valid(state.buf) then
        local start_line = vim.fn.getpos("'<")[2]
        local end_line = vim.fn.getpos("'>")[2]
        print(start_line, end_line)
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        local term_chan = vim.api.nvim_buf_get_var(state.buf, 'terminal_job_id')
        for _, line in ipairs(lines) do
            local exec_line = line:gsub('^%s+', ''):gsub('%s+$', '')
            -- It is important here to dont skip blank lines for languages that use indentation to spot end of function
            -- / loop etc. (like python). And it should be a blank line after each end of function / loop etc.
            vim.api.nvim_chan_send(term_chan, exec_line .. "\n")
        end
        if vim.api.nvim_win_is_valid(state.win) then
            local current_win = vim.api.nvim_get_current_win()
            vim.api.nvim_set_current_win(state.win)
            vim.cmd("normal! G")
            vim.api.nvim_set_current_win(current_win)
        end
    else
        print('Open a terminal first')
    end
end


M.subcommands.jump = function()
    if vim.api.nvim_get_current_win() == state.win then
        local current_line = vim.api.nvim_get_current_line()
        local filepath = nil
        local linenumber = nil
        for _, pattern in pairs(stacktrace_patterns) do
            filepath, linenumber = string.match(current_line, pattern)
            if filepath and linenumber then
                break
            end
        end
        if (not filepath) or (not linenumber) then
            print('Unable to find file path and line number from pattern list')
            return
        end
        vim.cmd.wincmd('k')
        vim.cmd('edit ' .. filepath)
        vim.cmd('normal! ' .. linenumber .. 'G_')
        print(filepath, linenumber)
    else
        print('You must be in the terminal window to run this command')
    end
end


return M
