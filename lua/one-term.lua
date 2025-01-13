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
        bg_color = opts.bg_color or nil,
        startinsert = opts.startinsert or false,
        relative_height = opts.relative_height or 0.35,
        local_options = {
            number = opts.local_options.number or false,
            relativenumber = opts.local_options.relativenumber or false,
            cursorline = opts.local_options.cursorline or false,
            colorcolumn = opts.local_options.colorcolumn or '',
            scrolloff = opts.local_options.scrolloff or 0,
        },
        -- regex patterns to go to file x line y using stacktrace
        stacktrace_patterns = opts.stacktrace_patterns or {
            '([^ :]*):([0-9]):', -- lua / cpp
            '^ *File "(.*)", line ([0-9]+)',  -- python
            '^(.*): line ([0-9]+)',  -- bash
        },
    }

    if not options.bg_color then
        -- Try to guess a good background color for the main terminal window.
        local factor = 0.75
        local normal_bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = 'Normal', create = false }).bg)

        local red = tonumber("0x" .. string.sub(normal_bg, 2, 3))
        local green = tonumber("0x" .. string.sub(normal_bg, 4, 5))
        local blue = tonumber("0x" .. string.sub(normal_bg, 6, 7))

        local hex_red = string.format("%02x", red * factor)
        local hex_green = string.format("%02x", green * factor)
        local hex_blue = string.format("%02x", blue * factor)

        options.bg_color = '#' .. hex_red .. hex_green .. hex_blue
    end

    builtin.setup_options(options)

    -- The main terminal background could be darker than the editor background
    vim.cmd.highlight('MainTerminalNormal guibg=' .. options.bg_color)

    -- Build subcommand completion list
    local choices = {}
    for subcommand, _ in pairs(builtin.subcommands) do
        table.insert(choices, subcommand)
    end
    table.sort(choices)

    -- User command
    vim.api.nvim_create_user_command(
        'Oneterm',
        function(o)
            load_command(unpack(o.fargs))
        end,
        {
            desc = 'Terminal main command (see :help one-term)',
            range = true,
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
