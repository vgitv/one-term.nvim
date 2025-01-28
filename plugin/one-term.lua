if vim.g.loaded_one_term == 1 then
    return
end

vim.api.nvim_create_user_command("Oneterm", function(o)
    require("one-term").load_command(unpack(o.fargs))
end, {
    desc = "Terminal main command (see :help one-term)",
    range = true,
    nargs = "*",
    complete = function(arglead, line, _)
        local l = vim.split(line, "%s+")
        local matches = {}
        local choices = {}

        -- Build subcommand completion list
        for subcommand, _ in pairs(require("builtin").subcommands) do
            table.insert(choices, subcommand)
        end
        table.sort(choices)

        if #l == 2 then
            for _, cmd in ipairs(choices) do
                if string.match(cmd, "^" .. arglead) then
                    table.insert(matches, cmd)
                end
            end
            return matches
        end
    end,
})

vim.g.loaded_one_term = 1
