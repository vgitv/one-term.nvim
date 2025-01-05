# Toggle-terminal.nvim

## Introduction

Simple terminal toggle plugin:

![toggle-terminal-overwiew](https://github.com/vgitv/resources/blob/main/toggle-terminal/images/toggle-terminal-overview.png)

## Features

* create a main terminal buffer and open it in a new window below the current one
* set relative height of the terminal window (compare to the current window)
* toggle the main terminal
* toggle the height of the terminal window
* terminal buffer is unlisted (hidden  from `:ls` command)
* terminal background color can be different than normal background color

## Why another toggle-terminal plugin?

99% of the time I only need one main terminal buffer, to execute the script I
am working on. For the remaining 1% I dont mind creating a terminal buffer
manually. Therefore most plugins out there are much more complex than is
necessary for my workflow.

## Terminal command usage exemples

Consider reading `:help toggle-terminal` for further informations. The
following sections will give a simple overview.

### Toggle window subcommand

```vim
" create a split window and open a new terminal
:Terminal toggle_window

" close the window (the terminal will still run in the background)
:Terminal toggle_window

" open the terminal again, this time occupying 80% of the current window
:Terminal toggle_window 0.8

" close the terminal window again
:Terminal toggle_window

" terminal buffer is unlisted
:ls

" you can see the terminal buffer this way
:ls!
```

### Toggle fullheight subcommand

```vim
" open a terminal window occupying 30% of the current height
:Terminal toggle_window 0.3

" 30% is not enough to see well... Let's increase the terminal height to
" the maximum
:Terminal toggle_fullheight

" back to 30%
:Terminal toggle_fullheight
```

## Installation

### Minimal quickstart with lazy.nvim

```lua
{
    'vgitv/toggle-terminal.nvim'
}
```

Toggle the main terminal with `:Toggleterminal` command.

### Longer example with lazy.nvim

Those are the defaults options, which can be changed.

```lua
{
    'vgitv/toggle-terminal.nvim',
    cmd = 'Toggleterminal',  -- lazy load on command
    keys = {
        { '<Leader>ts', ':Terminal toggle_window<CR>', desc = 'Toggle main terminal (small)' },
        { '<Leader>tb', ':Terminal toggle_window 0.8<CR>', desc = 'Toggle main terminal (big)' },
        { '<Leader><space>', ':Terminal toggle_fullheight<CR>', desc = 'Toggle main terminal full height' },
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

### Any other package manager

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
