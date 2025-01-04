local M = {}
local builtin = {}


local toggle_terminal_opts
local toggle_terminal_local_options

local state = {
    main_terminal = {
        buf = -1,
        win = -1,
        height = -1,
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

    return { buf = buf, win = win, height = height }
end


-- split current window
builtin.toggle_window = function(relative_height)
    -- FIXME use the default option instead
    -- print("###", toggle_terminal_opts.relative_height)
    relative_height = relative_height or toggle_terminal_opts.relative_height
    local height = math.floor(vim.o.lines * relative_height)
    if not vim.api.nvim_win_is_valid(state.main_terminal.win) then
        state.main_terminal = create_window_below { height = height, buf = state.main_terminal.buf }
        if vim.bo[state.main_terminal.buf].buftype ~= 'terminal' then
            -- The options should be set first because the presence of 'number' may change the way
            -- the prompt is display (becaus it changes the terminal width)
            set_main_terminal_options()
            -- Create terminal instance after setting local options
            vim.cmd.terminal()
        end
        if toggle_terminal_opts.startinsert then
            vim.cmd.startinsert()
        end
    else
        vim.api.nvim_win_hide(state.main_terminal.win)
    end
end

local full_height = false

builtin.toggle_fullheight = function()
    if vim.api.nvim_win_is_valid(state.main_terminal.win) then
        if full_height then
            vim.api.nvim_win_set_height(state.main_terminal.win, state.main_terminal.height)
            full_height = false
        else
            vim.api.nvim_win_set_height(state.main_terminal.win, vim.o.lines)
            full_height = true
        end
    end
end


local load_command = function(cmd, ...)
    builtin[cmd](...)
end


vim.api.nvim_create_user_command(
    'Terminal',
    function(opts)
        load_command(unpack(opts.fargs))
    end,
    {
        nargs = '*',
        complete = function(_, line, _)
            -- FIXME complete only for cmd arg
            local l = vim.split(line, "%s+")
            local n = #l - 1
            if n == 1 then
                -- command completion
                return { 'toggle_window', 'toggle_fullheight' }
            end
        end
    }
)


return M
