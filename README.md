# one-term.nvim - one and only terminal buffer

## Toggle a terminal window

![one-term-overwiew](https://github.com/vgitv/resources/blob/main/one-term/images/one-term-overview.png)

## Features

- [X] Create a main terminal buffer and open it in a new split window
- [X] Toggle the terminal window
- [X] Rerun the last command without leaving your buffer
- [X] Easily resize the terminal window
- [X] Customizable background terminal color
- [X] Terminal buffer is unlisted (hidden  from `:ls` command)
- [X] Send lines to the terminal buffer
- [X] Jump to file X line Y using stacktrace (see "Jump subcommand" section)

For a list of all sub-commands see below.

## Why another terminal plugin?

99% of the time I only need one main terminal buffer, to execute the script I
am working on. For the remaining 1% I dont mind creating a terminal buffer
manually. Therefore most plugins out there are much more complex than is
necessary for my workflow.

## Terminal subcommands

Consider reading `:help one-term` for further informations. The
following sections will give a simple overview.

| SUBCOMMAND | DESCRIPTION |
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
:Oneterm toggle_window

" close the window (the terminal will still run in the background)
:Oneterm toggle_window

" open the terminal again, this time occupying 80% of the current window
:Oneterm toggle_window 0.8

" close the terminal window again
:Oneterm toggle_window

" terminal buffer is unlisted
:ls

" you can see the terminal buffer this way
:ls!

" open a terminal window occupying 30% of the current height
:Oneterm toggle_window 0.3

" 30% is not enough to see well... Let's increase the terminal height to
" the maximum
:Oneterm toggle_fullheight

" back to 30%
:Oneterm toggle_fullheight

" When on a stacktrace, jump to the corresponding problematic code
:Oneterm jump

" Send current line to the terminal buffer
:Oneterm send_current_line

" Send currently selected lines to the terminal buffer
:Oneterm send_visual_lines

" Run previously executed command without leaving your current buffer
:Oneterm run_previous

" This command takes too much time... kill it without leaving your current buffer
:Oneterm kill

" Clear terminal window without leaving your current buffer
:Oneterm clear

" You dont need your terminal anymore, you can exit it without leaving your buffer
:Oneterm exit
```

## Installation

**NB:** one-term will not define any key mapping for you, it only
provides a user command. It's up to you to define you own mappings. Examples
are given below.

### Minimal example with lazy.nvim

```lua
{
    'vgitv/one-term.nvim',
    opts = {},
}
```

### Longer example with lazy.nvim

Those are the defaults options, which can be changed.

```lua
{
    'vgitv/one-term.nvim',
    cmd = 'Terminal',  -- lazy load on command
    keys = {
        { '<Leader>t', ':Oneterm toggle_window<CR>', desc = 'Toggle main terminal (small)', silent = true },
        { '<Leader>T', ':Oneterm toggle_window 0.8<CR>', desc = 'Toggle main terminal (big)', silent = true },
        { '<Leader><space>', ':Oneterm toggle_fullheight<CR>', desc = 'Toggle main terminal full height', silent = true },
        { '<Leader>j', ':Oneterm jump<CR>', desc = 'Jump to error line using stacktrace', silent = true },
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
        stacktrace_patterns = {
            '([^ ]*):([0-9]):', -- lua
            '^ *File "(.*)", line ([0-9]+)',  -- python
            '^(.*): line ([0-9]+)',  -- bash
        },
    },
}
```

### Neovim native package management

Make sure to add the plugin directory to your runtimepath, then call the setup
function:

```lua
-- simple usage
require('one-term').setup {}
```

```lua
-- advanced usage
require('one-term').setup {
    bg_color = '#000000',  -- main terminal background color
    startinsert = false,  -- start insert mode at term opening
    relative_height = 0.35,  -- relative height of the terminal window (beetween 0 and 1)
    local_options = {
        number = false,  -- no number in main terminal window
        relativenumber = false,  -- no relative number in main terminal window
        cursorline = false,  -- cursor line in main terminal window
        colorcolumn = '',  -- color column
    },
    stacktrace_patterns = {
        '([^ :]*):([0-9]):', -- lua / cpp
        '^ *File "(.*)", line ([0-9]+)',  -- python
        '^(.*): line ([0-9]+)',  -- bash
    },
}
```

## Precisions about some subcommands

### Jump subcommand

I did not test many languages. If this subcommand does not work for your
favorite language, it is up to you to define your own regular expressions (see
`stacktrace_patterns` option). You must write a regular expression with two
capturing groups, the first corresponding to the file name, the second to the
line number.

For instance if your stacktrace look like this:

```
Traceback (most recent call last):
  File "/home/vgitv/truc.py", line 1, in <module>
    prin("Hello")
    ^^^^
NameError: name 'prin' is not defined. Did you mean: 'print'?
```

You can have the following regular expression:

```
^ *File "(.*)", line ([0-9]+)
```

Note that the order of the regular expressions in `stacktrace_patterns` matters
because the first match will interrupt the search and try to jump to the
corresponding location.

Tested languages:

* lua
* cpp
* python
* bash

## How to contribute

Help and suggestions are welcome!

TODO

## Inspired from

* https://github.com/tjdevries/advent-of-nvim
* https://github.com/akinsho/toggleterm.nvim
