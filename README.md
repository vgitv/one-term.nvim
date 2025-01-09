# Toggle-terminal.nvim

## Introduction

Simple terminal toggle plugin:

![toggle-terminal-overwiew](https://github.com/vgitv/resources/blob/main/toggle-terminal/images/toggle-terminal-overview.png)

## Features

- [X] Create a main terminal buffer and open it in a new split window
- [X] Toggle the terminal window
- [X] Easily resize the terminal window
- [X] Customizable background terminal color
- [X] Terminal buffer is unlisted (hidden  from `:ls` command)
- [X] Send lines to the terminal buffer
- [X] Experimental: jump to file X line Y using stacktrace

## Why another toggle-terminal plugin?

99% of the time I only need one main terminal buffer, to execute the script I
am working on. For the remaining 1% I dont mind creating a terminal buffer
manually. Therefore most plugins out there are much more complex than is
necessary for my workflow.

## Terminal subcommands

Consider reading `:help toggle-terminal` for further informations. The
following sections will give a simple overview.

### Toggle-window

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

### Toggle-fullheight

```vim
" open a terminal window occupying 30% of the current height
:Terminal toggle_window 0.3

" 30% is not enough to see well... Let's increase the terminal height to
" the maximum
:Terminal toggle_fullheight

" back to 30%
:Terminal toggle_fullheight
```

### Jump

```vim
" When on a stacktrace, jump to the error source
:Terminal jump
```

### Send-current-line

```vim
" Send current line to the terminal buffer
:Terminal send_current_line
```

### Send-visual-lines

```vim
" Send currently selected lines to the terminal buffer
:Terminal send_visual_lines
```

## Installation

**NB:** toggle-terminal will not define any key mapping for you, it only
provides a user command. It's up to you to define you own mappings. Examples
are given below.

### Minimal example with lazy.nvim

```lua
{
    'vgitv/toggle-terminal.nvim',
    opts = {},
}
```

### Longer example with lazy.nvim

Those are the defaults options, which can be changed.

```lua
{
    'vgitv/toggle-terminal.nvim',
    cmd = 'Terminal',  -- lazy load on command
    keys = {
        { '<Leader>t', ':Terminal toggle_window<CR>', desc = 'Toggle main terminal (small)', silent = true },
        { '<Leader>T', ':Terminal toggle_window 0.8<CR>', desc = 'Toggle main terminal (big)', silent = true },
        { '<Leader><space>', ':Terminal toggle_fullheight<CR>', desc = 'Toggle main terminal full height', silent = true },
        { '<Leader>j', ':Terminal jump<CR>', desc = 'Jump to error line using stacktrace', silent = true },
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
        },
    },
}
```

### Neovim native package management

Make sure to add the plugin directory to your runtimepath, then call the setup
function:

```lua
-- simple usage
require('toggle-terminal').setup {}
```

```lua
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

## Jump to file X line Y using stacktrace

Tested languages:

* lua
* python
* bash

## Inspired from

* https://github.com/tjdevries/advent-of-nvim
* https://github.com/akinsho/toggleterm.nvim
