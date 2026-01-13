# How to contribute

Help and suggestions are welcome!

If you want to test things locally, you can add a custom subcommand by adding a
function to the table `M.subcommands` in the _builtin_ module. This function
must have at least one argument, which is the terminal instance.

For instance this function ...

```lua
M.subcommands.say_hello_to = function(term, name)
    print("Hello, " .. name .. "!")
end
```

... will allow you to run this command ...

```vim
:Oneterm say_hello_to Bob
```

... that will output:

```
Hello, Bob!
```

The `term` argument gives you access to the Terminal class instance.

You dont have to worry about the command completion, it will adapt
automatically. All you have to do is to write the function. Any command
parameters will be passed on to the function.
