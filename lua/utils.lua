-- Utils functions

local M = {}


---Set window local options given a window id
---@param win integer Window id
---@param opts table Local options to apply
M.set_local_options = function(win, opts)
    for opt_name, opt_value in pairs(opts) do
        vim.api.nvim_set_option_value(opt_name, opt_value, { win = win })
    end
end


---Create a split window below the current one
---@param opts table Options for the window creation
local create_window_below = function(opts)
    opts = opts or {}

    local enter = opts.enter or false
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
    local win = vim.api.nvim_open_win(buf, enter, win_config)

    return { buf = buf, win = win, height = height }
end


---Create a new terminal instance or open the buffer in a new window if it already exists
---@param state table Terminal state that will be updated
---@param relative_height number Relative height of the future window
---@param local_options table Local options to apply to the term buffer
---@param enter boolean Enter the window after it's creation
M.create_or_open_terminal = function(state, relative_height, local_options, enter)
    local height = math.floor(vim.o.lines * relative_height)
    local win_prop = create_window_below { height = height, buf = state.buf, enter = enter }
    state.buf = win_prop.buf
    state.win = win_prop.win
    state.height = win_prop.height

    if vim.bo[state.buf].buftype ~= 'terminal' then
        -- The options should be set first because the presence of 'number' may change the way
        -- the prompt is display (because it changes the terminal width)
        M.set_local_options(state.win, local_options)
        vim.api.nvim_set_option_value('winhighlight', 'Normal:MainTerminalNormal', {win = state.win})
        -- Create terminal instance after setting local options
        vim.api.nvim_buf_call(state.buf, vim.cmd.terminal)
        -- setting the buflisted option needs to be after calling terminal command
        vim.api.nvim_set_option_value('buflisted', false, {buf = state.buf})
    end

    state.chan = vim.bo[state.buf].channel
    state.full_height = false
end


---When it's needed to have a terminal window opened but without entering the terminal window
---@param state table Terminal state that will be updated
---@param relative_height number Relative height of the future window
---@param local_options table Local options to apply to the term buffer
M.ensure_open_terminal = function(state, relative_height, local_options)
    if not vim.api.nvim_win_is_valid(state.win) then
        M.create_or_open_terminal(state, relative_height, local_options, false)
    end
end


---Scroll to the bottom of the buffer
---@param win integer Window id
M.scroll_down = function(win)
    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(win)
    vim.cmd("normal! G")
    vim.api.nvim_set_current_win(current_win)
end


return M
