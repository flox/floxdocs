---
title: Customizing the shell environment
description: Using setup scripts, aliases, and environment variables to improve your workflows.
---

# Customizing the shell environment

Activating a Flox [environment][environment_concept] places you into a subshell.
You likely already have some customizations built into your shell from your shell's configuration (`.bashrc`, `.zshrc`, `config.fish`, etc), but it can be convenient to further customize your shell based on the project that you're working on.
This guide will walk you through leveraging various features of a Flox environment to improve your quality of life when developing a Rust project, but many of the ideas are applicable to other languages as well.

## Setup

Let's assume you have a Rust project that you regularly work on.
To do that work you would already have `cargo`, `rustc`, and a few other tools installed.
For more details on what it looks like to develop in Rust with Flox, see the [Rust language guide][rust_guide].

If you'd like to follow along with a real Flox environment, create an environment via [`flox init`][flox_init] and install the tools as shown below:

```{ .bash .copy }
mkdir mycli;
cd mycli;
flox init;
flox install rustc cargo libiconv
```

Then generate a basic "Hello, World" program using `cargo init` inside the environment:

```{ .bash .copy }
flox activate -- cargo init --bin .
```

## Vars, hook, or profile?

When customizing your shell environment you have three basic knobs you can turn:

- The `[vars]` section
- The `hook.on-activate` script
- The `[profile]` section

The logic for deciding where a customization should go is application specific, but there are some simple guidelines you can follow.
For a full discussion of what logic to place in which section and why, see the [activation concept page][activation_concept].
Otherwise, try this:

<!-- markdownlint-disable MD007 -->
- Are you setting an environment variable?
    - Is it a constant value?
        - If so, set it in the `[vars]` section.
        - If not, compute and `export` the variable in the `hook.on-activate` script.
- Are you sourcing a script (like activating a Python virtual environment)?
    - If so, do this in the `[profile]` section.
- Are you setting shell aliases?
    - If so, set them in the `[profile]` section.
- Are you doing general project setup actions (like creating a directory, etc)?
    - If so, do that in the `hook.on-activate` script.
<!-- markdownlint-enable MD007 -->

## Adding a directory to PATH

It can be convenient to quickly run commands against the development build of a program you're working on.
For instance, if you're working on a command line application you might want to check that the help text is formatted properly by interactively running `mycli -h`.

In our case, when we build the application `cargo` will place the compiled program in `target/debug`:

```text
mycli/
    .flox
    Cargo.toml
    Cargo.lock
    src/
        main.rs
    target/
        debug/
            mycli
```

If we want to run commands with this newly compiled `mycli`, we can either tell `cargo` to build it (again) and then run it, or we can add `target/debug` to `PATH` so that we can run `mycli` like any other program.
This second option is more convenient, so let's see how you can tell your Flox environment to do that for you automatically.

If we follow the logic listed above, we're wanting to modify an existing environment variable (`PATH`), so we'll do this in the `hook.on-activate` script.
Modify your `hook.on-activate` script to look like this:

```toml
[hook]
on-activate = '''
    export PATH="$PWD/target/debug:$PATH"
'''
```

Now if you activate the environment and build `mycli` for the first time, you should be able to run `mycli` without needing to type out the path to it (e.g. `target/debug/mycli`):

```console
$ flox activate
...
$ cargo build
...
$ mycli
Hello, World!
```

### Why do I need to exit and re-activate?

Any time the Flox CLI detects that you've changed a section of the manifest that it can't automatically make take effect, you'll need to exit and reactivate.
For instance, when you install a new package via [`flox install`][flox_install], the CLI is able to make that immediately available to you so there's no need to exit and re-activate.

However, editing the `hook.on-activate` script has no effect on the currently activated environment because the `hook.on-activate` script is only run during the activation process (and the same goes for `[profile]`).
Similarly, editing the `[vars]` section has no effect on the currently activated environment because the `hook.on-activate` and `[profile]` scripts may rely on the values of variables in `[vars]`, so for the sake of correctness it makes sense to re-run those scripts.

## Enabling feature flags

Now let's say that you've worked on `mycli` for a while and developed some features that aren't publicly available, but can be accessed by setting certain feature flags.
A common way to enable or disable feature flags is by environment variables.
If you want to be able to test out those features during development, this sounds like a great thing for Flox to do for you automatically.

Let's say that we have feature flags `MYCLI_ENABLE_COLOR` and `MYCLI_TURBO_MODE` and they're enabled when we set them to `"1"`.

Going back to our "vars, hook, or profile" logic, we see that we're trying to set new environment variables with constant values.
This means we'll want to set these variables in the `[vars]` section.
Edit your `[vars]` section to look like this:

```toml
[vars]
MYCLI_ENABLE_COLOR="1"
MYCLI_TURBO_MODE="1"
```

If you're currently in the environment, exit it and activate it again for the changes to take effect, otherwise you can simply activate the environment.
In the activated environment you should now see that these two variables are set:

```console
$ flox activate
...
$ echo $MYCLI_TURBO_MODE
1
```

## Adding shell aliases

Now let's say that you'd like to use `mycli` from anywhere on your system.
Let's also say that you have a `$HOME/bin` directory that you add to `PATH` in your shell's config file.
You might use this as a place to put programs you've compiled yourself that you want to be able to run from anywhere.
We're going to create an alias for your developer environment that will build `mycli` and copy it to this directory so that it's quick and easy to install `mycli` after completing a feature you've been working on.

Going back to our "vars, hook, or profile" logic, we see that we're creating a shell alias.
This means that we'll be adding it to the `[profile]` section.
However, the syntax for defining shell aliases is shell-specific, so we'll need to declare this alias in the subsection that corresponds to our shell.
For this tutorial we'll assume that you're an enlightened [fish shell][fish_shell] user, meaning that we'll edit our `profile.fish` script.

We'll call this alias `install-bin` and it will build `mycli` in "release" mode, i.e. with full optimizations so it runs as fast as possible.
Edit your `[profile]` section to look like this:

```toml
[profile]
fish = '''
    alias install-bin "cargo build --release && cp $PWD/target/release/mycli $HOME/bin/mycli"
'''
```

Again, if you're currently in the environment, exit it.
If you want to test this alias you'll also want to create the `$HOME/bin` directory.
Now if you activate the environment and run `install-bin` you should find a copy of `mycli` in `$HOME/bin`:

```console
$ flox activate
...
$ install-bin
...
$ ls $HOME/bin
mycli
```

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Multiple architecture environments][multi-arch-guide]

[environment_concept]: ../concepts/environments.md
[flox_activate]: ../manual/flox-activate.md
[multi-arch-guide]: ./multi-arch-environments.md
[rust_guide]: ../languages/rust.md
[flox_init]: ../manual/flox-init.md
[activation_concept]: ../concepts/activation.md
[fish_shell]: https://fishshell.com/
[flox_install]: ../manual/flox-install.md
