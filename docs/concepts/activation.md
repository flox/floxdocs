---
title: Activating environments
description: How an environment is activated, and how to make the most of it
---

# Activating environments

[Environments][environment-concept] are a central concept in Flox,
representing the tools you want to use, all of their dependencies,
various environment variables necessary to make them function properly,
_and_ all of your customizations.
Given that environments are such an important part of Flox,
it stands to reason that _how you use them_ is also an important part of Flox.

There are three different ways to use an environment,
and two different modes that an environment can be activated in.
At the end of the day, though, it all boils down to properly configuring a
shell.
The `hook` and `profile` scripts specified in your manifest are run as part of
configuring that shell.
Understanding when and why they're run will help you take full advantage
of Flox,
so let's walk through what it means to "activate" an environment and how it
works.

## Configuring the shell

When you "activate" an environment,
Flox configures a shell,
making all of the packages and environment variables specified in your
manifest available, as mentioned above.

The most basic way to activate an environment is simply by calling
`flox activate`,
which puts you into a subshell with everything configured:

```bash
$ flox activate
flox [myenv] $ # Now you can use your packages
```

One of the core features that makes Flox so attractive for development is that
the packages in your manifest are available when the environment is active,
and they're gone when it's inactive.
We do this by carefully setting a collection of environment variables,
some of which you may be familiar with, such as `PATH`, and others which you
may not have heard of like `ACLOCAL_PATH`, `RUST_SRC_PATH`, and others.

As an example, if you create an environment `myenv` and install `hello`,
Flox will place `<path to myenv>/.flox/run/<your system>.myenv.dev/bin` at the
beginning of your `PATH` variable so that `hello` will be selected from your
environment rather than from elsewhere on your system.

## Three different ways to activate

We mentioned above that there are three different ways to use an environment.

### Subshell

We've already mentioned the first method,
which is to put you into a subshell.
When you activate this way your existing shell is paused and you're put into a
new one configured by Flox.
Once this shell exits (via `exit` or `Ctrl-D`, for example), your original shell
is resumed and your are put back into it.

```d2 scale="1.0"
shape: sequence_diagram
user_shell: User shell
subshell: Subshell

user_shell -> subshell: flox activate
subshell -> subshell: do work in the subshell
subshell -> user_shell: exit
```

### In-place

This method is similar to the first in that you're still in an interactive
shell,
but in this case it's the original shell.

To make this happen you could do one of these options in Bash:

```bash
# Option 1
source <(flox activate)

# Option 2
eval "$(flox activate)"
```

In both cases Flox emits a script that configures the shell,
and the shell executes that code to configure itself.

```d2 scale="1.0"
shape: sequence_diagram
user_shell: User shell
user_shell -> user_shell: source <(flox activate)
user_shell."Back to you"
```

In order to configure a `default` environment that's activated for every new
shell,
you would put a line like this in your `.bashrc`, `.zshrc`, `.tcshrc`, or
`config.fish`.
You could do this manually, but Flox will also prompt you to do it for you
the first time you attempt to install a package in a directory without an
environment and with no environments currently active.

### Command

Sometimes you just want to run a command in the context of your environment,
maybe because you have some tools available in your environment that aren't
available outside the environment.

You could do this in a subshell:

- Enter the subshell via `flox activate`
- Run the command
- Exit the subshell via `exit`

You could do a similar thing with an in-place activation:

- Configure your existing shell with `source <(flox activate)`.
- Run the command
- Your shell is still configured by Flox when you're done

That's a lot of ceremony to run that one command though,
and the in-place activation leaves the environment still activated in your
shell,
which you may not want.

The easy way to do this is:

```bash
$ flox activate -- <your command>
```

This starts a Flox-configured subshell, runs your command,
and immediately exits to put you back into your shell.

```d2 scale="1.0" pad="1"
shape: sequence_diagram
user_shell: User shell
subshell: Subshell
user_shell -> subshell: "flox activate -- cmd"
subshell -> subshell: run "cmd"
subshell -> user_shell: automatic exit
user_shell."Back to you"
```

## Activation flow

In order to understand where `hook` and `profile` fit into the picture,
we need to explore the timeline of what an activation looks like.
Much of this is dictated by what gets inherited when you create subshells.
Don't feel like you need to understand this entirely in order to use Flox,
it's just here to help you if you want a deeper understanding.

### What's inherited by a subshell?

When you create a subshell,
you create a new process that _happens_ to be a shell.
A new process inherits the environment of its parent process by default,
meaning that it inherits all of the environment variables set by that process.
If the parent process is a shell,
the functions and aliases defined in the parent process (shell) are not passed
down to the subshell (unless you use [special options like `export -f`][bash-func-export]).
This means that if we want you to be able to define functions and aliases to be
used by _your_ shell in your environment,
we have to make your shell source their definitions.

### Timeline

In order to meet our constraints and user experience goals,
we activate an environment in a number of steps.
The steps for a subshell activation are shown in the diagram below,
and they're very similar for the other types of activation.
Let's break it down step by step.

```d2 scale="1.0"
shape: sequence_diagram
user_shell: User shell
proc: New process

user_shell -> proc: call "flox activate"
flox activate: {
  proc -> proc: exec bash activation_script.sh
}
bash: {
  proc -> proc: run setup scripts
  proc -> proc: set user variables
  proc -> proc: source hook.on-activate
  proc -> proc: exec FLOX_SHELL
}
FLOX_SHELL: {
  proc -> proc: "source [profile] scripts"
  Do work: {
    proc -> proc: Do your work inside the shell
  }
}
proc -> user_shell: exit
```

For a variety of reasons it's convenient to have the same process ID (PID)
throughout the lifecycle of the activated environment.
The way you tell the current process to run a different program is via the
`exec` command (which calls the `exec` system call).

`flox activate` `exec`s a Bash subshell with a script that's bundled with Flox,
and sets some environment variables to be present in that Bash subshell.
We use this Bash subshell to prepare the way for putting you into a configured
instance of your shell of choice.
In the diagram above your shell of choice is represented with the `FLOX_SHELL`
variable,
which is also the variable you can use to override which shell Flox uses when
you activate an environment.

As part of this activation script,
Flox runs some initial setup, then sets the variables you've provided in the
[[vars] section of your manifest][vars-section].
Next, the script _sources_ the `hook.on-activate` script that you've provided
in the [[hook] section of your manifest][hook-section].
Since this script is run by the Bash shell we're using,
you only need to worry about the synax and oddities of one shell when writing
this script.
This is convenient, but it comes with some tradeoffs.

This Bash subshell is _non-interactive_.
Some programs behave differently when they execute in a shell that's not
interactive,
and most shells will not (by default) expand aliases when run non-interactively.
Also, remember that any functions or aliases you define in this Bash subshell
via the `hook.on-activate` script will not be inherited by your shell later.

Finally, we `exec` your shell with some overrides that allow us to inject our
own configuration,
such as `source`ing the scripts defined in the
[[profile] section of your manifest][profile-section].
Once those scripts have been sourced,
we hand control back to you.
Since the scripts in the `[profile]` section are sourced by your shell,
this is where you can define aliases and functions that you'd like to be
available in your activated environment.

### hook vs. profile in a nutshell

So, that was a lot of technical detail.
To make life easier for you when it comes to writing scripts for your
environment,
here is some simple guidance:

**hook.on-activate**:

- Always Bash, so there's only one shell syntax and set of quirks to keep in mind.
- Can't use aliases.
- Can define functions to use within the hook, but they won't be passed down to other shells.
- _Can_ define environment variables that need to be computed.

**profile**:

- Syntax depends on the shell.
- Can define functions and aliases.
- Can source scripts needed for other programs to work properly e.g. the `activate` script for a Python virtual environment.
- _Can_ define environment variables that need to be computed.

In short, it's probably best to put as much as you can in `hook.on-activate`
until you have shell-specific needs, you need aliases, or you need to source
a third-party script into your shell.

## Attaching

Everything we've discussed so far is about what happens when you start a new
activation of an environment.
However, if you're simply activating a second instance of an environment,
all of the setup done in your `hook` and script will already have
been done,
so you would be doing the same exact thing.
In addition, you would be setting all of the same exact environment variables
from your `[vars]` `[hook]` sections as before.

In short, this would be doing a lot of pointless work.
For that reason, we record those environment variables and apply them to
subsequent activations rather than computing them again.
We call this "attaching" to an activation, and we do it automatically for you
to make activation as fast as possible.

```d2 scale="1.0"
shape: sequence_diagram
shell1: First shell
shell2: Second shell
files: \"Somewhere\"

shell1 -> shell1: flox activate
shell1 -> files: save environment variables
shell1."Activated"
shell2 -> shell2: flox activate
shell2 <- files: restore environment variables
shell2."Activated"
```

If you edit your manifest and activate in a new shell,
the whole activation process is run again and subsequent activations will
attach to this new version of the environment.

## Development vs. runtime mode

In addition to the different ways to use an activation,
there are two different "modes" to activate in:
development mode and runtime mode.

The default mode at the moment is development mode.
In development mode a package and all of its development dependencies are made
available.
As the name implies, this is useful at development time.
However, this may causes unexpected failures when layering environments or
when activating an environment system-wide.

For these reasons we also provide "runtime" mode,
which simply puts the requested packages in `PATH`
(and makes their `man` pages available).
This behavior is more in line with what you would expect from a system-wide
package manager like `apt`, `yum`, or `brew`.

## Conclusion

As you can see, there's a lot going on under the hood,
but at the end of the day it's just Unix fundamentals:
processes and environment variables.

This is what makes activating a Flox environment so fast.
There's no container to build and there's no VM to boot up.
It really is a return to basics, with our own special twist on it.

Hopefully after reading this you have a deeper understanding of how a Flox
environment is activated,
and you feel confident that you can write `[hook]` and `[profile]` scripts
that prepare your environment just how you like them.

[environment-concept]: ./services.md
[bash-func-export]: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-export
[vars-section]: ../concepts/manifest.md#vars-section
[hook-section]: ../concepts/manifest.md#hook-section
[profile-section]: ../concepts/manifest.md#profile-section
