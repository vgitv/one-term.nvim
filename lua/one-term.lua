-- Main plugin script

local M = {}
local builtin = require('builtin')


---Run a specific subcommand
---@param cmd string Subcommand name
---@param ... any Subcommand parameters
local load_command = function(cmd, ...)
    builtin.subcommands[cmd](...)
end


---The main terminal background could be darker than the editor background
---@param opts table
local set_term_bg_hi = function(opts)
    opts.factor = opts.factor or 0.75
    local color

    if opts.bg_color then
        color = opts.bg_color
    else
        -- Try to guess a good background color for the main terminal window.
        local normal_bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = 'Normal', create = false }).bg)

        local red = tonumber("0x" .. string.sub(normal_bg, 2, 3))
        local green = tonumber("0x" .. string.sub(normal_bg, 4, 5))
        local blue = tonumber("0x" .. string.sub(normal_bg, 6, 7))

        local hex_red = string.format("%02x", red * opts.factor)
        local hex_green = string.format("%02x", green * opts.factor)
        local hex_blue = string.format("%02x", blue * opts.factor)

        color = '#' .. hex_red .. hex_green .. hex_blue
    end

    vim.cmd.highlight('MainTerminalNormal guibg=' .. color)
end


---Plugin setup function
---@param opts table Main setup options
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

    -- make options visible from builtin module
    builtin.setup_options(options)

    -- define main terminal highlight group
    set_term_bg_hi({ bg_color = options.bg_color })

    -- when switching colorscheme, the bg color will adapt
    if not options.bg_color then
        vim.api.nvim_create_autocmd(
            'ColorScheme',
            {
                desc = 'Update terminal background color',
                group = vim.api.nvim_create_augroup('one_term_setup_augroup', { clear = true }),
                callback = function()
                    set_term_bg_hi({ bg_color = options.bg_color })
                end
            }
        )
    end

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
            complete = function(arglead, line, _)
                local l = vim.split(line, "%s+")
                local matches = {}
                if #l == 2 then
                    for _, cmd in ipairs(choices) do
                        if string.match(cmd, "^" .. arglead) then
                            table.insert(matches, cmd)
                        end
                    end
                    return matches
                end
            end
        }
    )
end


return M
