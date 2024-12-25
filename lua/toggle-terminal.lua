local M = {}

M.setup = function(opts)
    TOGGLE_TERMINAL_OPTS = {
        bg_color = opts.bg_color or '#000000',
        number = opts.number or false,
        relativenumber = opts.relativenumber or false,
        startinsert = opts.startinsert or false,
    }

    -- The main terminal background will be darker than the editor background
    -- this background color is consistent with kanagawa colorscheme
    vim.cmd.highlight('MainTerminalNormal guibg=' .. TOGGLE_TERMINAL_OPTS.bg_color)
end


local state = {
    main_terminal = {
        buf = -1,
        win = -1,
    }
}


local create_window_below = function(opts)
    opts = opts or {}

    -- Calculate window height
    local height = opts.height or math.floor(vim.o.lines * 0.35)

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
    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end


local toggle_terminal = function()
    if not vim.api.nvim_win_is_valid(state.main_terminal.win) then
        state.main_terminal = create_window_below { buf = state.main_terminal.buf }
        if vim.bo[state.main_terminal.buf].buftype ~= 'terminal' then
            vim.cmd.terminal()
            vim.bo.buflisted = false
            vim.opt_local.number = TOGGLE_TERMINAL_OPTS.number
            vim.opt_local.relativenumber = TOGGLE_TERMINAL_OPTS.relativenumber
            vim.opt_local.winhighlight = 'Normal:MainTerminalNormal'
        end
        if TOGGLE_TERMINAL_OPTS.startinsert then
            vim.cmd.startinsert()
        end
    else
        vim.api.nvim_win_hide(state.main_terminal.win)
    end
end


vim.api.nvim_create_user_command('Toggleterminal', toggle_terminal, {})


return M
