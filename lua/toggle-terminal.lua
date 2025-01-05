-- Main plugin script

local M = {}
local builtin = require('builtin')


-- default plugin options
local options


local load_command = function(cmd, ...)
    builtin.subcommands[cmd](...)
end


M.setup = function(opts)
    opts = opts or {}

    options = {
        bg_color = opts.bg_color or '#000000',
        startinsert = opts.startinsert or false,
        relative_height = opts.relative_height or 0.35,
        local_options = {
            number = opts.local_options.number or false,
            relativenumber = opts.local_options.relativenumber or false,
            cursorline = opts.local_options.cursorline or false,
            colorcolumn = opts.local_options.colorcolumn or '',
        }
    }

    -- The main terminal background could be darker than the editor background
    local bg_color = opts.bg_color or '#000000'
    vim.cmd.highlight('MainTerminalNormal guibg=' .. bg_color)

    builtin.setup_options(options)

    vim.api.nvim_create_user_command(
        'Terminal',
        function(o)
            load_command(unpack(o.fargs))
        end,
        {
            nargs = '*',
            complete = function(_, line, _)
                local l = vim.split(line, "%s+")
                local n = #l - 1
                if n == 1 then
                    local choices = {}
                    for subcommand, _ in pairs(builtin.subcommands) do
                        table.insert(choices, subcommand)
                    end
                    -- command completion
                    return choices
                end
            end
        }
    )
end


return M
