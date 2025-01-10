# Toggle-terminal.nvim

## Introduction

Simple terminal toggle plugin:

![toggle-terminal-overwiew](https://github.com/vgitv/resources/blob/main/toggle-terminal/images/toggle-terminal-overview.png)

## Features

- [X] Create a main terminal buffer and open it in a new split window
- [X] Toggle the terminal window
- [X] Rerun the last command without leaving your buffer
- [X] Easily resize the terminal window
- [X] Customizable background terminal color
- [X] Terminal buffer is unlisted (hidden  from `:ls` command)
- [X] Send lines to the terminal buffer
- [X] Jump to file X line Y using stacktrace

For a list of all sub-commands see below.

## Why another toggle-terminal plugin?

99% of the time I only need one main terminal buffer, to execute the script I
am working on. For the remaining 1% I dont mind creating a terminal buffer
manually. Therefore most plugins out there are much more complex than is
necessary for my workflow.

## Terminal subcommands

Consider reading `:help toggle-terminal` for further informations. The
following sections will give a simple overview.

| Subcommand | Description |
|------|------|
| `clear` | Clear the terminal window |
| `exit` | Exit the terminal process |
| `jump` | Jump from the stacktrace to the problematic code |
| `kill` | Kill currently running command |
| `run_previous` | Run previous command (without leaving your buffer) |
| `send_current_line` | Send current line to the terminal |
| `send_visual_lines` | Send visual lines to the terminal |
| `toggle_fullheight` | Toggle terminal full height |
| `toggle_window` | Toggle terminal window |

## Learn by examples

Obviously you should define key mappings for all or part of the following
commands. Remember that this plugin allows only one main terminal buffer, so
you dont have to worry about which terminal you will interact with. This makes
the commands much simple. Keep in mind that if you absolutely need a second
terminal buffer, you can still create it manually, the plugin will not mix them
up.

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

" open a terminal window occupying 30% of the current height
:Terminal toggle_window 0.3

" 30% is not enough to see well... Let's increase the terminal height to
" the maximum
:Terminal toggle_fullheight

" back to 30%
:Terminal toggle_fullheight

" When on a stacktrace, jump to the corresponding problematic code
:Terminal jump

" Send current line to the terminal buffer
:Terminal send_current_line

" Send currently selected lines to the terminal buffer
:Terminal send_visual_lines

" Run previously executed command without leaving your current buffer
:Terminal run_previous

" This command takes too much time... kill it without leaving your current buffer
:Terminal kill

" Clear terminal window without leaving your current buffer
:Terminal clear

" You dont need your terminal anymore, you can exit it without leaving your buffer
:Terminal exit
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

## How to contribute

Help and suggestions are welcome!

TODO

## Inspired from

* https://github.com/tjdevries/advent-of-nvim
* https://github.com/akinsho/toggleterm.nvim
