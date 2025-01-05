-- Main plugin script

local M = {}
local builtin = require('builtin')


local load_command = function(cmd, ...)
    builtin.subcommands[cmd](...)
end


M.setup = function(opts)
    opts = opts or {}

    -- Plutin options
    local options = {
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

    builtin.setup_options(options)

    -- The main terminal background could be darker than the editor background
    vim.cmd.highlight('MainTerminalNormal guibg=' .. options.bg_color)

    -- Build subcommand completion list
    local choices = {}
    for subcommand, _ in pairs(builtin.subcommands) do
        table.insert(choices, subcommand)
    end

    -- User command
    vim.api.nvim_create_user_command(
        'Terminal',
        function(o)
            load_command(unpack(o.fargs))
        end,
        {
            nargs = '*',
            complete = function(_, line, _)
                local l = vim.split(line, "%s+")
                if #l == 2 then
                    return choices
                end
            end
        }
    )
end


return M
