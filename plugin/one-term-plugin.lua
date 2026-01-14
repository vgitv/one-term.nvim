if vim.g.loaded_one_term == 1 then
    return
end

vim.api.nvim_create_user_command("Oneterm", function(o)
    require "one-term.init"
    require("one-term").call_subcommand(unpack(o.fargs))
end, {
    desc = "Terminal main command (see :help one-term)",
    range = true,
    nargs = "*",
    complete = function(arglead, line, _)
        local l = vim.split(line, "%s+")
        local matches = {}
        local subcommands = vim.tbl_keys(require "one-term.builtin")

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
