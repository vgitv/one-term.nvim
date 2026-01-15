local M = {}

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

---Override default options
function M.setup_options(user_options)
    M.options = vim.tbl_deep_extend("force", M.options, user_options or {})
end

return M
