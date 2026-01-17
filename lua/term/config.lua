local M = {}

M.options = {
    bg_color_factor = 0.75,
    startinsert = false,
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
    vertical = {
        relative_height = 0.35,
    },
    horizontal = {
        relative_width = 0.5,
    },
    floating = {
        relative_height = 0.7,
        relative_width = 0.7,
    },
}

---Override default options
function M.setup_options(user_options)
    M.options = vim.tbl_deep_extend("force", M.options, user_options or {})
end

return M
