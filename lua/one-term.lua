-- This is the main plugin script.
-- It's file name should not conflict with the directory containing modules, which can lead to unexpected errors.

local M = {}
local builtin = require "term.builtin"
local config = require "term.config"
local Terminal = require "term.terminal"

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
    require "term.init"
end

return M
