---
title: The default environment
description: Using Flox as your system package manager
---

# The default environment

In the typical development case you would create a directory for your project,
`flox init` to create an environment for it,
then `flox activate` in that directory when you want to work on that project.
The packages in that environment are available when the environment is active,
and they're unavailable otherwise.
But what about packages that you _always_ want available?

Without Flox, you may turn to your system's package manager
(`apt`, `yum`, `brew`, etc)
in order to install packages system-wide.
This has a number of drawbacks:

- You often only have a single package version to choose from.
- You often can't install multiple versions side-by-side.
- You can't ensure that multiple machines get the exact same version.
- You may not be able to back up the list of installed packages.

The Flox `default` environment doesn't have these problems,
so let's take a look at how to set it up.

## Initial setup

At the most basic level,
the `default` environment is simply an environment in your home directory.
Since you're unlikely to do development in your home directory we treat this
environment specially.

In some cases Flox will prompt to set up your `default` environment for you.
To create the `default` environment yourself,
simply navigate to your home directory and run [`flox init`][init].

```bash
$ cd ~
$ flox init
```

Once the environment has been created,
you'll want to configure your shell to activate the environment with every new
shell.
This can be done as part of the automatic setup,
or you can add a single line to your shell's RC file:

=== "Bash"

    Depending on the context, Bash will load different startup files.
    For that reason, we need to add a line to two different files:
    `.bashrc` and `.profile`.
    Add the following line to the very end of each of those files:

    ```bash
    eval "$(flox activate -m run)"
    ```

=== "Zsh"

    Add the following line to the very end of your `.zprofile` and `.zshrc`
    files:

    ```bash
    eval "$(flox activate -m run)"
    ```

=== "Fish"

    Add the following line to the very end of your `config.fish` file:

    ```fish
    flox activate -m run | source
    ```

=== "Tcsh"

    Add the following line to the very end of your `.tcshrc` file:

    ```bash
    eval "`flox activate -m run`"
    ```

---

Once you've added that line to your shell,
you'll need to restart your shell (or open a new one) for the changes to
take effect.
If you don't want to activate it automatically, the default
environment can simply be activated using `-d` parameter of the Flox CLI
like so:

```bash
flox activate -d "$HOME"
```

## Taking it for a spin

Now let's test out your new `default` environment.
If you're in an arbitrary directory and `apt install hello` you would expect
it to be available no matter what directory you're in.
Let's do the same with Flox.

Let's create a new directory that we know doesn't have an environment in it.

```bash
# Create and enter a new temporary directory
$ cd $(mktemp -d)
```

Now we'll install a package and see that it gets installed to the `default`
environment,
like you would expect from your system's package manager:

```bash
$ flox install hello
✅ 'hello' installed to environment 'default'
```

It worked (though you shouldn't be surprised, Flox is awesome)!

## Customization

Depending on when you created your default environment
(the default was changed recently),
you may also see `flox [default]` as part of your prompt for every new shell.
You can configure that with a single command:

=== "Do show the Flox prompt"

    ```bash
    $ flox config --set-bool hide_default_prompt false
    ```

=== "Don't show the Flox prompt"

    ```bash
    $ flox config --set-bool hide_default_prompt true
    ```

---

## Sharing

Since the `default` environment is "just" another Flox environment,
it's possible to push this environment and share it between machines.

From the machine with your `default` environment set up the way you like it,
run the [`flox push`][push] command:

```bash
$ cd ~
$ flox push
```

You may need to authenticate with FloxHub first,
but once that completes you're now able to share this environment with another
machine.
But wait, there's more!
Once you've pushed this machine's `default` environment to FloxHub,
you have the option to either use it as an upstream on another machine
(keeping them in sync),
or to use it as a starting point without otherwise linking the two machines.

=== "Keep the machines in sync"

    From the new machine:
    
    ```bash
    $ cd ~
    $ flox pull your_user/default
    ```

    Now on the new machine you'll [`flox pull`][pull] to get the latest updates
    from your other machines (e.g. newly installed packages),
    or `flox push` to push changes from this machine.
    Think of it like `git`, but simpler.

=== "Use as a starting point"

    From the new machine:
    
    ```bash
    $ cd ~
    $ flox pull --copy your_user/default
    ```

    Now you can install/uninstall packages all you like and it won't affect
    any other machine using this environment.

---

## Conclusion

Whether you want a reproducible package manager for your whole system,
or you want reproducible, cross-platform developer environments,
Flox has you covered.
Even better, if you want both a package manager _and_ developer environments,
with Flox you only need to learn one tool.

[init]: ../reference/command-reference/flox-init.md
[push]: ../reference/command-reference/flox-push.md
[pull]: ../reference/command-reference/flox-pull.md
