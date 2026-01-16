-- Here are defined the builtin subcommands

local M = {}

---Split current window
---@param term Terminal
function M.toggle_window(term)
    if not vim.api.nvim_win_is_valid(term.win) then
        term:create_or_open(true)
        if term.options.startinsert then
            vim.cmd.startinsert()
        end
    else
        vim.api.nvim_win_hide(term.win)
    end
end

---Toggle terminal fullscreen
---@param term Terminal
function M.toggle_fullscreen(term)
    if vim.api.nvim_win_is_valid(term.win) then
        if term:is_fullscreen() then
            -- Restore current layout
            term:set_layout(term.layout)
        else
            -- Fullscreen
            term:activate_fullscreen()
        end
    else
        print "The terminal window must be open to run this command"
    end
end

---Send line under cursor into the terminal
---@param term Terminal
function M.send_current_line(term)
    local current_line = vim.api.nvim_get_current_line()
    -- trim line
    local exec_line = current_line:gsub("^%s+", ""):gsub("%s+$", "")
    if exec_line == "" then
        return
    end
    term:ensure_open()
    term:exec(exec_line)
end

---Send visually selected lines to the terminal
---@param term Terminal
function M.send_visual_lines(term)
    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    term:ensure_open()
    for _, line in ipairs(lines) do
        local exec_line = line:gsub("^%s+", ""):gsub("%s+$", "")
        -- It is important here to dont skip blank lines for languages that use indentation to spot end of function
        -- / loop etc. (like python). And it should be a blank line after each end of function / loop etc.
        term:exec(exec_line)
    end
end

---Send visual selection
---@param term Terminal
function M.send_visual_selection(term)
    local start_pos = vim.fn.getpos "'<"
    local end_pos = vim.fn.getpos "'>"
    local start_row, start_col = unpack(start_pos, 2, 3)
    local end_row, end_col = unpack(end_pos, 2, 3)
    -- Why -1? Because the doc says:
    -- Indexing is zero-based. Row indices are end-inclusive, and column indices are end-exclusive.
    local text = vim.api.nvim_buf_get_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, {})
    term:ensure_open()
    for _, line in ipairs(text) do
        local exec_line = line:gsub("^%s+", ""):gsub("%s+$", "")
        -- It is important here to dont skip blank lines for languages that use indentation to spot end of function
        -- / loop etc. (like python). And it should be a blank line after each end of function / loop etc.
        term:exec(exec_line)
    end
end

---Jump to error location
---@param term Terminal
function M.jump(term)
    if vim.api.nvim_get_current_win() == term.win then
        local current_line = vim.api.nvim_get_current_line()
        local filepath = nil
        local linenumber = nil
        for _, pattern in pairs(term.options.errorformat) do
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
---@param term Terminal
function M.run_previous(term)
    if not vim.api.nvim_buf_is_valid(term.buf) then
        -- If the main terminal doesnt exist, the previous command has good chances to be a nvim command!
        -- This will prevent from accidentally opening a new neovim instance inside the terminal buffer.
        print "You need to create a terminal buffer first"
        return
    end

    term:ensure_open()

    -- Send Ctrl-p signal to the terminal
    term:exec "\x10"
end

-- TODO: use a method to know if the terminal exists
---Clear terminal
---@param term Terminal
function M.clear(term)
    if vim.api.nvim_win_is_valid(term.win) then
        -- Send Ctrl-l signal to the terminal
        vim.api.nvim_chan_send(term.chan, "\x0c")
    else
        print "The terminal window must be open to run this command"
    end
end

---Kill currently running command
---@param term Terminal
function M.kill(term)
    if vim.api.nvim_win_is_valid(term.win) then
        -- Send Ctrl-c signal to the terminal
        vim.api.nvim_chan_send(term.chan, "\x03")
    else
        print "The terminal window must be open to run this command"
    end
end

---Exit terminal
---@param term Terminal
function M.exit(term)
    if vim.api.nvim_buf_is_valid(term.buf) then
        -- Send Ctrl-d signal to the terminal
        vim.api.nvim_chan_send(term.chan, "\x04")
        print "Terminal successfully exited"
    else
        print "No terminal to exit"
    end
end

-- FIXME: should work in all layouts
---Resize terminal window
---@param term Terminal
---@param mouvement string Mouvement for window resizing like +5 or -2 for instance
function M.resize(term, mouvement)
    if vim.api.nvim_win_is_valid(term.win) then
        local current_height = vim.api.nvim_win_get_height(term.win)
        local height
        if string.match(mouvement, "^+[0-9]+$") then
            height = current_height + tonumber(string.sub(mouvement, 2))
        elseif string.match(mouvement, "^-[0-9]+$") then
            height = current_height - tonumber(string.sub(mouvement, 2))
        else
            print "ERROR - Invalid argument"
            return
        end
        vim.api.nvim_win_set_height(term.win, height)
    else
        print "The terminal window must be open to run this command"
    end
end

---Run arbitrary command
---@param term Terminal
---@param ... any Command line
function M.run(term, ...)
    local cmd = table.concat({ ... }, " ")
    term:ensure_open()
    term:exec(cmd)
end

---Launch commands from a .nvim/launch.lua config file
---@param term Terminal
---@param name string configuration name to launch
function M.launch(term, name)
    name = name or "default"
    local launch_config = dofile ".nvim/launch.lua"
    local cmd = table.concat(launch_config.configurations[name]["cmd"], " ")
    term:ensure_open()
    term:exec(cmd)
end

---Cycle through layouts
---@param term Terminal
function M.next_layout(term)
    term:set_layout(term.layout % #term.options.enabled_layouts + 1)
end

return M
