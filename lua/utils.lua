-- Utils functions

local M = {}

---Set window local options given a window id
---@param win integer Window id
---@param opts table Local options to apply
function M.set_local_options(win, opts)
    for opt_name, opt_value in pairs(opts) do
        vim.api.nvim_set_option_value(opt_name, opt_value, { win = win })
    end
end

---Create a split window below the current one
---@param opts table Options for the window creation
function M.create_window_below(opts)
    opts = opts or {}

    local enter = opts.enter or false
    local height = opts.height or math.floor(vim.o.lines * 0.5)

    -- Get or create new buffer
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end

    -- Define window configuration
    local win_config = {
        split = "below",
        win = -1,
        height = height,
    }

    -- Open window
    local win = vim.api.nvim_open_win(buf, enter, win_config)

    return { buf = buf, win = win, height = height }
end

---Scroll to the bottom of the buffer
---@param win integer Window id
function M.scroll_down(win)
    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(win)
    vim.cmd "normal! G"
    vim.api.nvim_set_current_win(current_win)
end

return M
