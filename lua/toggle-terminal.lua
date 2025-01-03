local M = {}


local toggle_terminal_opts
local toggle_terminal_local_options

local state = {
    main_terminal = {
        buf = -1,
        win = -1,
    }
}


M.setup = function(opts)
    toggle_terminal_opts = {
        startinsert = opts.startinsert or false,
        relative_height = opts.relative_height or 0.35,
    }

    toggle_terminal_local_options = {
        number = opts.local_options.number or false,
        relativenumber = opts.local_options.relativenumber or false,
        cursorline = opts.local_options.cursorline or false,
        colorcolumn = opts.local_options.colorcolumn or '',
    }

    -- The main terminal background could be darker than the editor background
    local bg_color = opts.bg_color or '#000000'
    vim.cmd.highlight('MainTerminalNormal guibg=' .. bg_color)
end


local set_main_terminal_options = function()
    -- Force options
    vim.bo.buflisted = false
    vim.opt_local.winhighlight = 'Normal:MainTerminalNormal'

    -- Options that can be changed
    for opt_name, opt_value in pairs(toggle_terminal_local_options) do
        vim.opt_local[opt_name] = opt_value
    end
end


local create_window_below = function(opts)
    opts = opts or {}

    -- Calculate window height
    local height = opts.height or math.floor(vim.o.lines * toggle_terminal_opts.relative_height)

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


-- split current window
local toggle_terminal_split = function()
    if not vim.api.nvim_win_is_valid(state.main_terminal.win) then
        state.main_terminal = create_window_below { buf = state.main_terminal.buf }
        if vim.bo[state.main_terminal.buf].buftype ~= 'terminal' then
            -- Create terminal instance
            vim.cmd.terminal()
            set_main_terminal_options()
        end
        if toggle_terminal_opts.startinsert then
            vim.cmd.startinsert()
        end
    else
        vim.api.nvim_win_hide(state.main_terminal.win)
    end
end


-- replace current window
local toggle_terminal_replace = function()
    if vim.api.nvim_buf_is_valid(state.main_terminal.buf) then
        if vim.api.nvim_get_current_buf() == state.main_terminal.buf then
            vim.cmd.buffer('#')
        else
            vim.cmd.buffer(state.main_terminal.buf)
            if toggle_terminal_opts.startinsert then
                vim.cmd.startinsert()
            end
        end
    else
        state.main_terminal.buf = vim.api.nvim_create_buf(false, true)
        vim.cmd.buffer(state.main_terminal.buf)
        vim.cmd.terminal()
        set_main_terminal_options()
        if toggle_terminal_opts.startinsert then
            vim.cmd.startinsert()
        end
    end
end


local toggle_terminal_cmd = {
    split = toggle_terminal_split,
    replace = toggle_terminal_replace,
}

vim.api.nvim_create_user_command(
    'Toggleterminal',
    function(opts)
        toggle_terminal_cmd[opts.fargs[1]]()
    end,
    {
        nargs = 1,
        complete = function(ArgLead, CmdLine, CursorPos)
            return { 'split', 'replace' }
        end
    }
)


return M
