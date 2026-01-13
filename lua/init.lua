-- Plugin initialisation.
-- This init module must be run even if the setup function is not called so the plugin is usable with default options
-- without the need of calling the setup function with empty arguments.

local config = require "config"

---Compute main terminal background color
---@param factor number Factor to apply to red / green / blue parts of Normal bg color
---@return string: Terminal background color in the form #XXXXXX
local function get_term_bg(factor)
    factor = math.max(0, factor or 0.75)

    -- Try to guess a good background color for the main terminal window.
    local normal_bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal", create = false }).bg)

    local red = tonumber("0x" .. string.sub(normal_bg, 2, 3))
    local green = tonumber("0x" .. string.sub(normal_bg, 4, 5))
    local blue = tonumber("0x" .. string.sub(normal_bg, 6, 7))

    -- if factor > 1, be sure not to exceed FF (=255)
    local hex_red = string.format("%02x", math.min(red * factor, 255))
    local hex_green = string.format("%02x", math.min(green * factor, 255))
    local hex_blue = string.format("%02x", math.min(blue * factor, 255))

    return "#" .. hex_red .. hex_green .. hex_blue
end

---Set terminal highlight group for later background color
local function set_term_hl()
    local color = get_term_bg(config.options.bg_color_factor)
    vim.api.nvim_set_hl(0, "MainTerminalNormal", { bg = color })
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
