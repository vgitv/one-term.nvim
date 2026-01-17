-- Utils functions

local M = {}
M.create_window = {}

---Set window local options given a window id
---@param win integer Window id
---@param opts table Local options to apply
function M.set_local_options(win, opts)
    for opt_name, opt_value in pairs(opts) do
        vim.api.nvim_set_option_value(opt_name, opt_value, { win = win })
    end
end

---Get or create new buffer
local function get_buf(buf)
    if vim.api.nvim_buf_is_valid(buf) then
        return buf
    else
        return vim.api.nvim_create_buf(false, true)
    end
end

---Create a split window below
---@param opts table Options for the window creation
function M.create_window.vertical(opts)
    opts = opts or {}

    local enter = opts.enter or false
    local buf = get_buf(opts.buf)

    -- Define window configuration
    local win_config = {
        split = "below",
        win = -1,
        height = opts.height,
    }

    -- Open window
    local win = vim.api.nvim_open_win(buf, enter, win_config)

    return buf, win
end

---Create a split window to the right
---@param opts table Options for the window creation
function M.create_window.horizontal(opts)
    opts = opts or {}

    local enter = opts.enter or false
    local buf = get_buf(opts.buf)

    -- Define window configuration
    local win_config = {
        split = "right",
        win = -1,
        width = opts.width,
    }

    -- Open window
    local win = vim.api.nvim_open_win(buf, enter, win_config)

    return buf, win
end

---Create a floating window
---@param opts table Options for the window creation
function M.create_window.floating(opts)
    opts = opts or {}

    local enter = opts.enter or false
    local border = opts.border or "rounded"
    local buf = get_buf(opts.buf)

    -- Calculate the position to center the window
    local col = math.floor((vim.o.columns - opts.width) / 2)
    local row = math.floor((vim.o.lines - opts.height) / 2)

    -- Define window configuration
    local win_config = {
        relative = "editor",
        height = opts.height,
        width = opts.width,
        col = col,
        row = row,
        style = "minimal",
        border = border,
    }

    -- Open window
    local win = vim.api.nvim_open_win(buf, enter, win_config)

    return buf, win
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
