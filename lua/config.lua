local M = {}

local init_called = false

---The main terminal background could be darker than the editor background
---@param opts table
M.get_term_bg = function(opts)
    local factor = math.max(0, opts.factor)

    -- Try to guess a good background color for the main terminal window.
    local normal_bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal", create = false }).bg)

    -- TODO math.max if factor > 1
    local red = tonumber("0x" .. string.sub(normal_bg, 2, 3))
    local green = tonumber("0x" .. string.sub(normal_bg, 4, 5))
    local blue = tonumber("0x" .. string.sub(normal_bg, 6, 7))

    local hex_red = string.format("%02x", red * factor)
    local hex_green = string.format("%02x", green * factor)
    local hex_blue = string.format("%02x", blue * factor)

    return "#" .. hex_red .. hex_green .. hex_blue
end

M.options = {
    bg_color_factor = 0.75,
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

---Initialisation function
local init = function()
    local color = M.get_term_bg { factor = M.options.bg_color_factor }
    vim.cmd.highlight("MainTerminalNormal guibg=" .. color)
end

---Override default options
function M.setup(user_options)
    M.options = vim.tbl_deep_extend("force", M.options, user_options or {})
    init()
    init_called = true
end

-- The init function must be run even if the setup function is not called
if not init_called then
    init()
end

-- when switching colorscheme, the bg color will adapt
vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Update terminal background color",
    group = vim.api.nvim_create_augroup("one_term_setup_augroup", { clear = true }),
    callback = function()
        print(M.options.bg_color_factor)
        local bg_color = M.get_term_bg { factor = M.options.bg_color_factor }
        vim.cmd.highlight("MainTerminalNormal guibg=" .. bg_color)
    end,
})

return M
