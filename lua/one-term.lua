-- Main plugin script

local M = {}
local builtin = require "one-term.builtin"
local config = require "one-term.config"
local Terminal = require "one-term.terminal"

---Run a specific subcommand
---@param subcmd_name string Subcommand name
---@param ... any Subcommand parameters
function M.call_subcommand(subcmd_name, ...)
    local term = Terminal:get_instance()
    builtin[subcmd_name](term, ...)
end

---Plugin setup function
---@param opts table Main setup options
function M.setup(opts)
    opts = opts or {}
    config.setup(opts)
    -- Init should be inside the setup function because it should run last (if the user calls the setup function)
    require "one-term.init"
end

return M
