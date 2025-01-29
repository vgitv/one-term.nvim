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
    require "init"
end

return M
