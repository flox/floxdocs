---
title: The default environment
description: Using Flox as your system package manager
---

# The default environment

Flox installs packages into environments,
and every environment is attached to a specific directory.
However, one directory, your home directory, is special.

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

This is where Flox and its `default` environment come in.
Since this is a Flox environment
you get all of the benefits that come along with it:

- Cross-platform by default
- 3+ years of package versions
- Reproducible
- The ability to push an environment to FloxHub to ensure that a record of your
  environment exists external to your machine (or simply to share with others).

Let's take a look at how to set up your `default` environment.

## Initial setup

At the most basic level,
the `default` enviroment is simply an environment in your home directory.
Since you're unlikely to do development in your home directory we treat this
environment specially.

To create the `default` environment yourself,
simply navigate to your home directory and run [`flox init`][init].

In some cases Flox can set up your `default` environment for you.
If you attempt to install a package and there are no other environments
available to install to,
Flox will prompt to create a `default` environment for you.

```d2 scale="1.0"
install: flox install
q1: Any active environments?
manual: Create one manually
q2: Environment in current directory?
automatic: Create one automatically

install -> q1
q1 -> manual: Yes
q1 -> q2: No
q2 -> manual: Yes
q2 -> automatic: No
```

Your choice will be recorded so that we don't pester you in the future.

Once the environment has been created,
you'll want to activate the environment with every new shell.
This can be done as part of the automatic setup,
or you can add a single line to your shell's RC file:

=== "Bash"

    Add the following line to the very end of your `.bashrc` file:

    ```bash
    eval "$(flox activate -m run)"
    ```

=== "Zsh"

    Add the following line to the very end of your `.zshrc` file:

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
