local M = {}

---The main terminal background could be darker than the editor background
---@param opts table
local get_term_bg = function(opts)
    local factor = opts.factor or 0.75
    local color

    if opts.bg_color then
        color = opts.bg_color
    else
        -- Try to guess a good background color for the main terminal window.
        local normal_bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal", create = false }).bg)

        local red = tonumber("0x" .. string.sub(normal_bg, 2, 3))
        local green = tonumber("0x" .. string.sub(normal_bg, 4, 5))
        local blue = tonumber("0x" .. string.sub(normal_bg, 6, 7))

        local hex_red = string.format("%02x", red * factor)
        local hex_green = string.format("%02x", green * factor)
        local hex_blue = string.format("%02x", blue * factor)

        color = "#" .. hex_red .. hex_green .. hex_blue

        return color
    end
end

M.options = {
    bg_color = get_term_bg {},
    startinsert = false,
    relative_height = 0.35,
    local_options = {
        number = false,
        relativenumber = false,
        cursorline = false,
        colorcolumn = "",
        scrolloff = 0,
    },
    -- regex patterns used to jump to the error location
    errorformat = {
        "([^ :]*):([0-9]):", -- lua / cpp
        '^ *File "(.*)", line ([0-9]+)', -- python
        "^(.*): line ([0-9]+)", -- bash
    },
}

---Override default options
function M.setup(user_options)
    M.options = vim.tbl_deep_extend("force", M.options, user_options or {})
end

return M
