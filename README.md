# Toggle-terminal.nvim

## Introduction

Simple terminal toggle plugin:

![toggle-terminal-overwiew](https://github.com/vgitv/resources/blob/main/toggle-terminal/images/toggle-terminal-overview.png)

## Features

* create a main terminal buffer and open it in a new window below the current one
* toggle the main terminal
* terminal buffer is unlisted (hidden  from `:ls` command)
* terminal background color can be different than normal background color

## Why another toggle-terminal plugin?

99% of the time I only need one main terminal buffer, to execute the script I
am working on. For the remaining 1% I dont mind creating a terminal buffer
manually. Therefore most plugins out there are much more complex than is
necessary for my workflow.

## Minimal quickstart with lazy.nvim

```lua
{
    'vgitv/toggle-terminal.nvim'
}
```

Toggle the main terminal with `:Toggleterminal` command.

## Longer example with lazy.nvim

Those are the defaults options, which can be changed.

```lua
{
    'vgitv/toggle-terminal.nvim',
    cmd = 'Toggleterminal',  -- lazy load on command
    keys = {
        { '<Leader>t', ':Toggleterminal<CR>', desc = 'Toggle main terminal (split current window)' },
        { '<Leader>f', ':Toggleterminal 1<CR>', desc = 'Toggle main terminal (full height)' },
    },  -- lazy load on keymap
    opts = {
        bg_color = '#000000',  -- main terminal background color
        startinsert = false,  -- start insert mode at term opening
        relative_height = 0.35,  -- relative height of the terminal window (beetween 0 and 1)
        local_options = {
            number = false,  -- no number in main terminal window
            relativenumber = false,  -- no relative number in main terminal window
            cursorline = false,  -- cursor line in main terminal window
            colorcolumn = '',  -- color column
        }
    },
}
```

## Any other package manager

Make sure to add the plugin in your runtimepath, then call the setup function:

```lua
-- simple usage
require('toggle-terminal').setup {}

-- advanced usage
require('toggle-terminal').setup {
    bg_color = '#000000',  -- main terminal background color
    startinsert = false,  -- start insert mode at term opening
    relative_height = 0.35,  -- relative height of the terminal window (beetween 0 and 1)
    local_options = {
        number = false,  -- no number in main terminal window
        relativenumber = false,  -- no relative number in main terminal window
        cursorline = false,  -- cursor line in main terminal window
        colorcolumn = '',  -- color column
    }
}
```

## Inspired from

* https://github.com/tjdevries/advent-of-nvim
* https://github.com/akinsho/toggleterm.nvim
