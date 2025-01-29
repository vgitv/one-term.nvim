-- This init module must be run even if the setup function is not called so the plugin is usable with default options
-- without the need of calling the setup function with empty arguments.

local config = require "config"

---The main terminal background could be darker than the editor background
---@param opts table
local get_term_bg = function(opts)
    local factor = math.max(0, opts.factor)

    -- Try to guess a good background color for the main terminal window.
    local normal_bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal", create = false }).bg)

    -- TODO math.max("FF", factor) if factor > 1
    local red = tonumber("0x" .. string.sub(normal_bg, 2, 3))
    local green = tonumber("0x" .. string.sub(normal_bg, 4, 5))
    local blue = tonumber("0x" .. string.sub(normal_bg, 6, 7))

    local hex_red = string.format("%02x", red * factor)
    local hex_green = string.format("%02x", green * factor)
    local hex_blue = string.format("%02x", blue * factor)

    return "#" .. hex_red .. hex_green .. hex_blue
end

---Initialisation function
local set_term_hl = function()
    local color = get_term_bg { factor = config.options.bg_color_factor }
    vim.cmd.highlight("MainTerminalNormal guibg=" .. color)
end

-- when switching colorscheme, the bg color will adapt
vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Update terminal background color",
    group = vim.api.nvim_create_augroup("one_term_setup_augroup", { clear = true }),
    callback = function()
        set_term_hl()
    end,
})

set_term_hl()
