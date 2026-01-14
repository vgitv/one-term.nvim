-- This plugin file is automatically sourced by nvim, and define the Oneterm user command.
-- It allows the one-term plugin to lazily load itself the first time the Oneterm command is fired (by delaying the
-- require calls).

if vim.g.loaded_one_term == 1 then
    return
end

vim.api.nvim_create_user_command("Oneterm", function(o)
    -- If the setup function is not called, we must nevertheless call the init module. With the 'require' keyword, we
    -- make sure this will run only once.
    require "term.init"
    require("one-term").call_subcommand(unpack(o.fargs))
end, {
    desc = "Terminal main command (see :help one-term)",
    range = true,
    nargs = "*",
    complete = function(arglead, line, _)
        local l = vim.split(line, "%s+")
        local matches = {}
        local subcommands = vim.tbl_keys(require "term.builtin")

        table.sort(subcommands)

        if #l == 2 then
            for _, cmd in ipairs(subcommands) do
                if string.match(cmd, "^" .. arglead) then
                    table.insert(matches, cmd)
                end
            end
            return matches
        end
    end,
})

vim.g.loaded_one_term = 1
