# One-term - One single terminal [![Stylua](https://github.com/vgitv/one-term.nvim/actions/workflows/stylua.yml/badge.svg)](https://github.com/vgitv/one-term.nvim/actions/workflows/stylua.yml)

> Neovim Lua plugin to toggle a terminal window and more.


## Table of contents

* [Overview](#overview)
* [Features](#features)
* [Oneterm subcommands](#oneterm-subcommands)
* [Learn by examples](#learn-by-examples)
* [Installation](#installation)
    + [With Neovim native package management](#with-neovim-native-package-management)
    + [With lazy.nvim](#with-lazynvim)
* [Details about the jump subcommand](#details-about-the-jump-subcommand)
* [Inspired from](#inspired-from)


## Overview

![one-term-overwiew](https://github.com/vgitv/resources/blob/main/one-term/images/one-term-overview.png)


## Features

- [X] Create a main terminal buffer and open it in a new split window
- [X] Toggle the terminal window
- [X] Rerun the last command without leaving your buffer
- [X] Easily resize the terminal window
- [X] Automatically darken terminal background
- [X] Send lines to the terminal buffer
- [X] Jump from a command output to the corresponding error location in your code
- [X] Unlisted terminal buffer (hidden  from `:ls` command)

For a list of all sub-commands see below.

> [!NOTE]
> _Why another terminal plugin?_
>
> 99% of the time I only need one main terminal buffer, to execute the script I
> am working on. For the remaining 1% I dont mind creating a terminal buffer
> manually. Therefore most plugins out there are much more complex than is
> necessary for my workflow. Besides I have added some functionnalities that I
> think interesting.


## Oneterm subcommands

This plugin provides only one user command named _Oneterm_ and does not define
any default keybindings for nvim. The _Oneterm_ command takes at least one
argument which is the subcommand name. The subcommand may (or may not) have
arguments.

`:Oneterm <subcommand> [args...]`

The subcommands are listed below. Consider reading `:help one-term` for further
informations.

| SUBCOMMAND              | DESCRIPTION                                        |
|-------------------------|----------------------------------------------------|
| `clear`                 | Clear the terminal window                          |
| `exit`                  | Exit the terminal process                          |
| `jump`                  | Jump to the error location using a command output  |
| `kill`                  | Kill currently running command                     |
| `launch`                | Launch commands read from a config file            |
| `resize`                | Resize the terminal window                         |
| `run`                   | Run an arbitrary command                           |
| `run_previous`          | Run previous command (without leaving your buffer) |
| `send_current_line`     | Send current line to the terminal                  |
| `send_visual_lines`     | Send visual lines to the terminal                  |
| `send_visual_selection` | Send visual selection to the terminal              |
| `toggle_fullheight`     | Toggle terminal full height                        |
| `toggle_window`         | Toggle terminal window                             |


## Learn by examples

Obviously you should define key mappings for all or part of the following
commands. Remember that this plugin allows only one main terminal buffer, so
you dont have to worry about which terminal you will interact with. This makes
the commands much simple. Keep in mind that if you absolutely need a second
terminal buffer, you can still create it manually, the plugin will not mix them
up.

```vim
" Create a split window and open a new terminal
:Oneterm toggle_window

" Close the window (the terminal will still run in the background)
:Oneterm toggle_window

" Open the terminal again, this time occupying 80% of the current window
:Oneterm toggle_window 0.8

" Close the terminal window again
:Oneterm toggle_window

" Terminal buffer is unlisted
:ls

" You can see the terminal buffer this way
:ls!

" Open a terminal window occupying 30% of the current height
:Oneterm toggle_window 0.3

" 30% is not enough to see well... Let's increase the terminal height to the maximum
:Oneterm toggle_fullheight

" Back to 30%
:Oneterm toggle_fullheight

" When on an error message, jump to the corresponding problematic code
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

> [!TIP]
> one-term will not define any key mapping for you, it only provides a user
> command. It's up to you to define you own mappings.


### With Neovim native package management

_Oneterm_ can be loaded using native package management (see `:help packages`).
Just clone the repository into your `pack/*/start/` directory and restart
Neovim. If you are satisfied with the defaults, nothing else is required, you
can use the `Oneterm` command right away.

Note that _Oneterm_ will lazy-load itself on the first `Oneterm` command, thus
avoiding time-consuming startup.

If you want to set specific options, you must explicitly call the setup
function. Just pick the options you are interested in and put them into your
nvim configuration. Here are the default options:

```lua
require('one-term').setup {
    bg_color_factor = 0.75,  -- factor to compute terminal bg color
    startinsert = false,  -- start insert mode at term opening
    relative_height = 0.35,  -- relative height of the terminal window (beetween 0 and 1)
    local_options = {
        number = false,  -- no number in main terminal window
        relativenumber = false,  -- no relative number in main terminal window
        cursorline = false,  -- cursor line in main terminal window
        colorcolumn = '',  -- color column
    },
    errorformat = {
        '([^ :]*):([0-9]):',  -- lua / cpp
        '^ *File "(.*)", line ([0-9]+)',  -- python
        '^(.*): line ([0-9]+)',  -- bash
    },
}
```

See `:help one-term-configuration` for details about configuration items.


### With lazy.nvim

#### Minimal example

If you are satisfied with the defaults, there is no need to call the setup
function (that means you dont even have to define an empty _opt_ key). Note
that _Oneterm_ will lazy-load itself on the first `Oneterm` command.

```lua
{
    'vgitv/one-term.nvim'
}
```

#### Longer example

Those are the defaults options, which can be changed. Dont copy this
configuration as is, just pick the options you want to override. Feel free to
add lazy loading options and keymaps.

```lua
{
    'vgitv/one-term.nvim',
    opts = {
        bg_color_factor = 0.75,  -- factor to compute terminal bg color
        startinsert = false,  -- start insert mode at term opening
        relative_height = 0.35,  -- relative height of the terminal window (beetween 0-1)
        local_options = {
            number = false,  -- no number in main terminal window
            relativenumber = false,  -- no relative number in main terminal window
            cursorline = false,  -- cursor line in main terminal window
            colorcolumn = '',  -- color column
        },
        errorformat = {
            '([^ :]*):([0-9]):', -- lua
            '^ *File "(.*)", line ([0-9]+)',  -- python
            '^(.*): line ([0-9]+)',  -- bash
        },
    },
}
```

See `:help one-term-configuration` for details about configuration items.


## Details about the jump subcommand

This command may overlap in some circumstances the native errorformat
functionnality (see `:h error-file-format`). If you are using a compiler and
you build your program with `:make` you should probably use this native
functionnality instead, and commands like `:copen`, `:cnext` etc. The _jump_
subcommand is convenient when you run a script directly in the main terminal
window and when this script returns error messages (without calling `:make`
command). You can then jump directly to the problematic location.

If this subcommand does not work for your favorite language, it is up to you to
define your own regular expressions (see `errorformat` option). You must write
a regular expression with two capturing groups, the first corresponding to the
file name, the second to the line number.

For instance if your command output looks like this:

    Traceback (most recent call last):
    File "/home/vgitv/truc.py", line 1, in <module>
        prin("Hello")
        ^^^^
    NameError: name 'prin' is not defined. Did you mean: 'print'?

You can have the following regular expression:

    ^ *File "(.*)", line ([0-9]+)

Note that the order of the regular expressions in `errorformat` matters
because the first match will interrupt the search and try to jump to the
corresponding location.

The default configuration should work at least for the following languages:

* lua
* cpp
* python
* bash


## Inspired from

* https://github.com/tjdevries/advent-of-nvim
* https://github.com/akinsho/toggleterm.nvim
