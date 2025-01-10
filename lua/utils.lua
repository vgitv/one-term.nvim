-- Utils functions

local M = {}


---Set window local options given a window id
---@param win integer
---@param opts table
M.set_local_options = function(win, opts)
    for opt_name, opt_value in pairs(opts) do
        vim.api.nvim_set_option_value(opt_name, opt_value, {win = win})
    end
end


---Create a split window below the current one
---@param opts table
local create_window_below = function(opts)
    opts = opts or {}
    -- for key, value in pairs(opts) do
    --     print(key, value)
    -- end
    opts.enter = opts.enter

    -- Calculate window height
    local height = opts.height or math.floor(vim.o.lines * 0.5)

    -- Get or create new buffer
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end

    -- Define window configuration
    local win_config = {
        split = 'below',
        win = 0,
        height = height,
    }

    -- Open window
    local win = vim.api.nvim_open_win(buf, opts.enter, win_config)

    return { buf = buf, win = win, height = height }
end


---Create a new terminal instance or open the buffer in a new window if it already exists
---@param relative_height number
---@param enter boolean
---@param buf integer
---@param chan number
---@param local_options table
M.create_or_open_terminal = function(relative_height, enter, buf, chan, local_options)
    local height = math.floor(vim.o.lines * relative_height)
    local state = create_window_below { height = height, buf = buf, enter = enter }

    if vim.bo[state.buf].buftype ~= 'terminal' then
        -- The options should be set first because the presence of 'number' may change the way
        -- the prompt is display (becaus it changes the terminal width)
        M.set_local_options(state.win, local_options)
        vim.api.nvim_set_option_value('buflisted', false, {buf = state.buf})
        vim.api.nvim_set_option_value('winhighlight', 'Normal:MainTerminalNormal', {win = state.win})
        -- Create terminal instance after setting local options
        vim.api.nvim_buf_call(state.buf, vim.cmd.terminal)
        chan = vim.api.nvim_buf_get_var(state.buf, 'terminal_job_id')
    end
    state.chan = chan

    return state
end


---When it's needed to have a terminal window opened but without entering the terminal window
---@param relative_height number
---@param state table
---@param local_options table
M.ensure_open_terminal = function(relative_height, state, local_options)
    if not vim.api.nvim_win_is_valid(state.win) then
        state = M.create_or_open_terminal(relative_height, false, state.buf, state.chan, local_options)
    end

    return state
end


---Scroll to the bottom of the buffer
---@param win integer
M.scroll_down = function(win)
    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(win)
    vim.cmd("normal! G")
    vim.api.nvim_set_current_win(current_win)
end


return M
