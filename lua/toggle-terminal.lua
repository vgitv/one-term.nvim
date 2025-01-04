local M = {}
local builtin = {}


-- default plugin options
local options = {
    bg_color = '#000000',  -- main terminal background color
    startinsert = false,  -- start insert mode at term opening
    relative_height = 0.35,  -- relative height of the terminal window (beetween 0 and 1)
    local_options = {
        number = false,  -- no number in main terminal window
        relativenumber = false,  -- no relative number in main terminal window
        cursorline = false,  -- cursor line in main terminal window
        colorcolumn = '',  -- color column
    }
}

local state = {
    buf = -1,
    win = -1,
    height = -1,
    full_height = false,
}


M.setup = function(opts)
    opts = opts or {}

    options.bg_color = opts.bg_color or options.bg_color
    options.startinsert = opts.startinsert or options.startinsert
    options.relative_height = opts.relative_height or options.relative_height
    options.local_options.number = opts.local_options.number or options.local_options.number
    options.local_options.relativenumber = opts.local_options.relativenumber or options.local_options.relativenumber
    options.local_options.cursorline = opts.local_options.cursorline or options.local_options.cursorline
    options.local_options.colorcolumn = opts.local_options.colorcolumn or options.local_options.colorcolumn

    -- The main terminal background could be darker than the editor background
    local bg_color = opts.bg_color or '#000000'
    vim.cmd.highlight('MainTerminalNormal guibg=' .. bg_color)
end


local set_main_terminal_options = function()
    -- Force options
    vim.bo.buflisted = false
    vim.opt_local.winhighlight = 'Normal:MainTerminalNormal'

    -- Options that can be changed
    for opt_name, opt_value in pairs(options.local_options) do
        vim.opt_local[opt_name] = opt_value
    end
end


local create_window_below = function(opts)
    opts = opts or {}

    -- Calculate window height
    local height = opts.height or math.floor(vim.o.lines * options.relative_height)

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
    relative_height = relative_height or options.relative_height
    local height = math.floor(vim.o.lines * relative_height)
    if not vim.api.nvim_win_is_valid(state.win) then
        state = create_window_below { height = height, buf = state.buf }
        if vim.bo[state.buf].buftype ~= 'terminal' then
            -- The options should be set first because the presence of 'number' may change the way
            -- the prompt is display (becaus it changes the terminal width)
            set_main_terminal_options()
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


builtin.toggle_fullheight = function()
    if vim.api.nvim_win_is_valid(state.win) then
        if state.full_height then
            vim.api.nvim_win_set_height(state.win, state.height)
            state.full_height = false
        else
            vim.api.nvim_win_set_height(state.win, vim.o.lines)
            state.full_height = true
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
