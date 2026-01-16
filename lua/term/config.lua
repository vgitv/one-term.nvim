local M = {}

M.options = {
    bg_color_factor = 0.75,
    startinsert = false,
    relative_height = 0.35,
    relative_width = 0.5,
    floating_relative_height = 0.8,
    floating_relative_width = 0.8,
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
    enabled_layouts = {
        "vertical",
        "horizontal",
        "floating",
    },
}

---Override default options
function M.setup_options(user_options)
    M.options = vim.tbl_deep_extend("force", M.options, user_options or {})
end

return M
