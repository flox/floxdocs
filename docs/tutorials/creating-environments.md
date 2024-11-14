---
title: Creating environments
description: Reproducible environments for any project.
---

# Creating environments

You can use Flox to **set up an [environment][environment_concept]** for a new
or existing project.
Flox environments can either be activated in a new sub-shell or within the
current shell,
and they provide dependencies that take precedence over dependencies you may
have installed on your system.
Your existing dependencies are not modified in any way.
When you leave the Flox environment everything will return to its original
state.

This guide uses an `example-project` but you can follow along in your own
projects as well.

## Initialize a project

Let's set up a project called `example-project` using the
[`flox init`][flox_init] command:

``` console
$ git init example-project && cd example-project
Initialized empty Git repository in /Users/your-username/example-project/.git/
```

``` console
$ flox init
✨ Created environment example-project (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
```

Once an [environment][environment_concept] has been created,
you will notice some files have appeared in a `.flox` directory wherever you ran
[`flox init`][flox_init].
This is where an environment's declarative configuration is stored by default,
and can be checked into version control.

## Search, show, and install packages

We have an environment,
but it's empty.
Flox has over 80,000 open source and licensable packages to install in your
environment.
Search for and install packages using [`flox search`][flox_search],
[`flox show`][flox_show], and [`flox install`][flox_install].

Let's assume `example-project` is a nodejs/npm project.
Begin by searching for `nodejs` with [`flox search`][flox_search] in Flox:

``` console
$ flox search nodejs
nodejs              Event-driven I/O framework for the V8 JavaScript engine
nodejs_20           Event-driven I/O framework for the V8 JavaScript engine
nodejs_latest       Event-driven I/O framework for the V8 JavaScript engine
nodejs-18_x         Event-driven I/O framework for the V8 JavaScript engine
nodejs_18           Event-driven I/O framework for the V8 JavaScript engine
nodejs-16_x         Event-driven I/O framework for the V8 JavaScript engine
nodejs_16           Event-driven I/O framework for the V8 JavaScript engine
nodejs-14_x         Event-driven I/O framework for the V8 JavaScript engine
nodejs_14           Event-driven I/O framework for the V8 JavaScript engine

Showing 10 of 30 results. Use 'flox search nodejs --all' to see the full list.
Use 'flox show <package>' to see available versions
```
!!! note "Note"
    Don't see what you're looking for? Try `flox search <search-term> --all`.
    Still missing? Reach out to us on our [forum][discourse] for assistance.

For more detail about a specific package, such as the available versions,
use [`flox show`][flox_show].

Here we're showing nodejs:

``` console
$ flox show nodejs
nodejs - Event-driven I/O framework for the V8 JavaScript engine
    nodejs@18.18.2
    nodejs@18.18.0
    nodejs@18.17.1
    nodejs@18.16.1
    nodejs@18.9.0
    nodejs@18.7.0
    ...
```

Once you've found the right package, you can install it with
[`flox install`][flox_install].

```
$ flox install nodejs
✅ 'nodejs' installed to environment example-project at /Users/myuser/example-project
```

!!! note "Note"
    Flox will warn you if you install a package that requires licensing.
    Ensure you have a license for the package before using it with Flox.

In addition to applications, let's **install system dependencies** that nodejs
may need,
such as a certificate generator.

```
$ flox search mkcert
mkcert  A simple tool for making locally-trusted development certificates

Use `flox show <package>` to see available versions
```

```
$ flox install mkcert
✅ 'mkcert' installed to environment example-project at /Users/myuser/example-project
```

## Enter and use the environment

Now we need to activate the environment with the
[`flox activate`][flox_activate] command to make the packages we installed
available.
When an environment is activated,
you will see your terminal's prompt change.
This example demonstrates that the packages are now available by running
`which node` and `which mkcert`.

```
$ flox activate
```

```
flox [example-project] $ which node
/Users/myuser/example-project/.flox/run/aarch64-darwin.flox/bin/node
```

```
flox [example-project] $ which mkcert
/Users/myuser/example-project/.flox/run/aarch64-darwin.flox/bin/mkcert
```
!!! note "Note"
    Some terminal themes may override Flox's terminal prompt changes.
    You will still be able to activate and use the environment.

## Customize the shell hook and environment variables

The activation process of your Flox environment can be
customized by editing the [environment's declarative manifest][manifest_concept]
with [`flox edit`][flox_edit].
This is useful for doing environment initialization,
safely working with secrets,
printing instructions for other developers,
and more.

Let's add a simple instruction to `example-project`'s environment.
To interactively edit and validate your environment,
use Flox's built-in edit function which uses your default terminal `$EDITOR`:

```
flox [example-project] $ flox edit
```

From within the editor,
add a custom activation script under the `[hook]` block:

``` toml title="manifest.toml"
# List packages you wish to install in your environment under
# the `[install]` table
[install]
nodejs.pkg-path = "nodejs"
mkcert.pkg-path = "mkcert"
# hello.pkg-path = "hello"
# nodejs = { version = "^18.4.2", pkg-path = "nodejs_18" }

# Set an environment variable. These variables may not reference once another.
[vars]
# message = "Howdy"
# pass-in = "$some-env-var"

# Set your activation hook ( run when entering the environment )
# You can write this inline with the `on-activate` field.
[hook]
on-activate = """
  echo ""
  echo "Start the server with 'npm start'"
  echo ""
"""
```

Save changes to the file.

!!! note "Note"
    Edits made with [`flox edit`][flox_edit] will be validated and built
    immediately.
    Edits made to the [manifest][manifest_concept] with external software like
    an IDE will be validated when you run [`flox activate`][flox_activate].

Test out the new shell hook by running `exit` and
[`flox activate`][flox_activate] again:

```
flox [example-project] $ exit
```

```
$ flox activate

Start the server with 'npm start'

flox [example-project] $
```

## Exit the environment

We're done!
To exit the last [environment][environment_concept] activated,
use the `exit` command or the shell shortcut, `CTRL + D`.

```
flox [example-project] $ exit
$ 
```

[flox_init]: ../reference/command-reference/flox-init.md
[flox_search]: ../reference/command-reference/flox-search.md
[flox_show]: ../reference/command-reference/flox-show.md
[flox_install]: ../reference/command-reference/flox-install.md
[discourse]: https://discourse.floxdev.com/
[flox_activate]: ../reference/command-reference/flox-activate.md
[flox_edit]: ../reference/command-reference/flox-edit.md
[sharing_guide]: ./sharing-environments.md
[layering_guide]: ./layering-multiple-environments.md
[manifest_concept]: ../concepts/manifest.md
[environment_concept]: ../concepts/environments.md
[customizing_guide]: ./customizing-environments.md

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Sharing environments][sharing_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Layering multiple environments][layering_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Customizing the shell hook][customizing_guide]
