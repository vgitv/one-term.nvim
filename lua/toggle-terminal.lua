-- Main plugin script

local M = {}
local builtin = require('builtin')


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

    builtin.setup_options(options)
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
