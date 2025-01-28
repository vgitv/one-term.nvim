-- Main plugin script

local M = {}
local builtin = require "builtin"
local config = require "config"

---Run a specific subcommand
---@param cmd string Subcommand name
---@param ... any Subcommand parameters
M.load_command = function(cmd, ...)
    builtin.subcommands[cmd](...)
end

---Plugin setup function
---@param opts table Main setup options
M.setup = function(opts)
    opts = opts or {}
    config.setup(opts)
end

vim.cmd.highlight("MainTerminalNormal guibg=" .. config.options.bg_color)

-- when switching colorscheme, the bg color will adapt
if not config.options.bg_color then
    vim.api.nvim_create_autocmd("ColorScheme", {
        desc = "Update terminal background color",
        group = vim.api.nvim_create_augroup("one_term_setup_augroup", { clear = true }),
        callback = function()
            local bg_color = config.get_term_bg {}
            vim.cmd.highlight("MainTerminalNormal guibg=" .. bg_color)
        end,
    })
end

return M
