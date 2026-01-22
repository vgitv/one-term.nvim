local Window = require "term.win.window"

local VerticalWindow = Window:new {
    split = "below",
    win = -1,
    width = math.floor(vim.o.lines / 2),
}

return VerticalWindow
