---
title: Flox in 5 minutes
description: Get started with creating Flox environments.
---

# Flox in 5 minutes

Flox is a virtual environment and package manager all in one.
With Flox you create development environments that put you into reproducible
subshells with dependencies provided and configured for you.
Even better, these environments layer so you can prepare different environments
for different contexts and stack them when needing to work across contexts.

Finally, Flox environments are portable across architecture,
operating system, and the entire software lifecycle.

Let's see what it looks like to bring Flox to one of your existing projects.

## Quick start

1. Install Flox.
2. Create an environment with `flox init`.
3. Find your dependencies with `flox search` and `flox show`.
4. Install dependencies with `flox install`
5. Add environment variables, shell hooks, and services with `flox edit`.
6. Enter the environment with `flox activate`
7. Play around, see if everything works, what's missing, etc.
8. Leave the environment via `exit` or Ctrl-D.

Let's walk through those steps and explain in more detail.

## Install Flox 

Start by [installing `flox`][install_flox].

## Create an environment

We'll start by creating an environment for your project,
and we'll pretend that your project is called `my_project`.

Flox installs packages into _environments_ as opposed to installing them into
globally accessible directories in various places on your system.
This allows you to have different versions of your tools across different
projects without them interfering or conflicting.

`cd` into your project and initialize the environment with [`flox init`][init].

For Python, Node.js, and Go projects this will display a prompt asking if you
would like Flox to automatically do some language-specific setup for you.

=== "Python"

    ```
    $ cd my_project

    my_project $ flox init
    Flox detected a Python project with the following Python provider(s):

    * latest python (requirements.txt)

      Installs latest python (3.12.5) with pip bundled.
      Adds hooks to setup and use a venv.
      Installs dependencies to the venv from: requirements.txt

    ! Would you like Flox to set up a standard Python environment?
    You can always change the environment's manifest with 'flox edit'
    > Yes - with latest python
      No
      Show suggested modifications for latest python
    [Use '--auto-setup' to apply Flox recommendations in the future.]
    ...select yes...
    ✨ Created environment 'my_project' (aarch64-darwin)
    ✅ 'python3' installed to environment 'my_project'

    Next:
      $ flox search <package>    <- Search for a package
      $ flox install <package>   <- Install a package into an environment
      $ flox activate            <- Enter the environment
      $ flox edit                <- Add environment variables and shell hooks
    ```

    If your Python project contains a `requirements.txt`,
    a Poetry `pyproject.toml`, or a generic `pyproject.toml`,
    you'll be asked whether you'd like Flox to install Python, `pip`, and
    Poetry (if applicable).

    If you accept, it will also create a virtual environment that's activated
    automatically when you activate your Flox environment.

    Note that the Flox Catalog already contains thousands of Python packages,
    so you may not need `poetry`, `pipenv`, `pdm`, etc for package management.
    That's right, with Flox you may be able to ditch your Python package
    manager for something that works universally across all languages!

=== "Node.js"

    ```
    $ cd my_project

    my_project $ flox init
    Flox detected a package.json

    Flox can add the following to your environment:
    * nodejs 20.17.0 with npm bundled
    * An npm installation hook

    ! Would you like Flox to apply this suggestion?
    You can always change the environment's manifest with 'flox edit'
    > Yes
      No
      Show suggested modifications
    [Use '--auto-setup' to apply Flox recommendations in the future.]
    ...select yes...
    ✨ Created environment 'my_project' (aarch64-darwin)
    ✅ 'nodejs' installed to environment 'my_project'

    Next:
      $ flox search <package>    <- Search for a package
      $ flox install <package>   <- Install a package into an environment
      $ flox activate            <- Enter the environment
      $ flox edit                <- Add environment variables and shell hooks
    ```

    If your project contains a `package.json` or a `yarn.lock`,
    you'll be asked whether you'd like Flox to install `npm` or `yarn`
    with versions matching those in the `package.json` or `yarn.lock` file
    if found in the Flox Catalog.

    If you accept, it will also add a hook that calls either `npm install` or
    `yarn` when activating the environment so that your dependencies are up to
    date.

    Note that the Flox Catalog already contains thousands of Node.js packages,
    so you may not need `npm`, `yarn`, `pnpm`, etc for package management.

=== "Go"

    ```
    $ cd my_project

    my_project $ flox init
    Flox detected a go.mod file in the current directory.

    Go projects typically need:
    * Go
    * A shell hook to apply environment variables


    ! Would you like Flox to apply the standard Go environment?
    You can always revisit the environment's declaration with 'flox edit'
    > Yes
      No
      Show environment manifest
    [Use '--auto-setup' to apply Flox recommendations in the future.]
    ...select yes...
    ✨ Created environment 'my_project' (aarch64-darwin)
    ✅ 'go' installed to environment 'my_project'

    Next:
      $ flox search <package>    <- Search for a package
      $ flox install <package>   <- Install a package into an environment
      $ flox activate            <- Enter the environment
      $ flox edit                <- Add environment variables and shell hooks
    ```

    If your project contains a `go.mod` or `go.work` you'll be asked whether
    you'd like Flox to install `go` and add a hook that both installs your
    Go dependencies and sets `GOENV`.

=== "Other"

    ```
    $ cd my_project

    my_project $ flox init
    ✨ Created environment 'my_project' (aarch64-darwin)

    Next:
      $ flox search <package>    <- Search for a package
      $ flox install <package>   <- Install a package into an environment
      $ flox activate            <- Enter the environment
      $ flox edit                <- Add environment variables and shell hooks
    ```

    For projects that don't contain files for the specific languages listed
    above, don't worry, you'll start from a blank slate.
    We're about to show you how to add dependencies, so read on.

---

Notice that this created an environment called `my_project`,
named after the directory the environment was created in.
You can select a different name at creation time via `flox init --name`,
or you can change it at any other point in time via `flox edit --name`.

This created a `.flox` directory with a few files in it,
and you'll want to check this into source control like you would for your
source code.
We'll discuss what those files are later,
but for now let's add your project's dependencies.

## Search for dependencies

Different package managers will name packages slightly differently from one
another,
so the next thing we'll do is find the packages we need with
[`flox search`][search].

=== "Python"

    If you started from scratch you probably need a Python interpreter:
    ```
    my_project $ flox search python3
    python3      High-level dynamically-typed programming language
    python39     High-level dynamically-typed programming language
    python38     A high-level dynamically-typed programming language
    python37     A high-level dynamically-typed programming language
    python36     A high-level dynamically-typed programming language
    python313    High-level dynamically-typed programming language
    python312    High-level dynamically-typed programming language
    python311    High-level dynamically-typed programming language
    python310    High-level dynamically-typed programming language
    python3Full  High-level dynamically-typed programming language

    Showing 10 of 174 results. Use `flox search python3 --all` to see the full list.

    Use 'flox show <package>' to see available versions
    ```

    You can see that the Flox Catalog contains Python versions ranging from
    3.6 up through 3.13 (which is still a release candidate at the time of
    writing).
    Whether you need an old version or whether you want to try out an upcoming
    release,
    Flox has your Python needs covered.

    Let's look for the Flask web framework next:
    ```
    my_project $ flox search flask
    pflask                      Lightweight process containers for Linux
    python39Packages.flask      The Python micro framework for building web applications
    python38Packages.flask      The Python micro framework for building web applications
    python37Packages.flask      A microframework based on Werkzeug, Jinja 2, and good intentions
    python312Packages.flask     Python micro framework for building web applications
    python311Packages.flask     Python micro framework for building web applications
    python310Packages.flask     The Python micro framework for building web applications
    python39Packages.flask-wtf  Simple integration of Flask and WTForms.
    python39Packages.flask_wtf  Simple integration of Flask and WTForms.
    python39Packages.flask-api  Browsable web APIs for Flask

    Showing 10 of 391 results. Use `flox search flask --all` to see the full list.

    Use 'flox show <package>' to see available versions
    ```

    Notice that (aside from the first result, which isn't what we're looking
    for) all of the `flask` packages have a `python3*Packages.` prefix.
    In short, packages in the Flox Catalog are stored in hierarchical
    namespaces.
    For more details about package naming see the [Flox Catalog][catalog]
    documentation page.

=== "Node.js"

    If you started from scratch you probably need Node.js,
    so let's search for that:
    ```
    my_project $ flox search node
    renode    Virtual development framework for complex embedded systems
    nodenv    Manage multiple NodeJS versions
    nodejs    Event-driven I/O framework for the V8 JavaScript engine
    nodemon   Framework for converting Left-To-Right (LTR) Cascading Style Sheets(CSS) to Right-To-Left (RTL)
    nodehun   Hunspell binding for NodeJS that exposes as much of Hunspell as possible and also adds new features
    imnodes   Small, dependency-free node editor for dear imgui
    tox-node  Server application to run tox node written in pure Rust
    nodeinfo  Command line tool to query nodeinfo based on a given domain
    node-gyp  Node.js native addon build tool
    node2nix  Generate Nix expressions to build NPM packages

    Showing 10 of 326 results. Use `flox search node --all` to see the full list.

    Use 'flox show <package>' to see available versions

    Related search results for 'nodejs':
    nodejs     Event-driven I/O framework for the V8 JavaScript engine
    nodejs_22  Event-driven I/O framework for the V8 JavaScript engine
    nodejs_21  Event-driven I/O framework for the V8 JavaScript engine 
    ```

    Note that `node` wasn't exactly the right package name,
    but Flox provided some suggestions at the bottom so we know the correct one.

=== "Go"

    If you started from scratch you probably need a Go toolchain:
    ```
    my_project $ flox search go
    go    Go Programming language
    wgo   Live reload for Go apps
    qgo   Go client based on Qt5
    gox   Dead simple, no frills Go cross compile tool
    got   Version control system which prioritizes ease of use and simplicity over flexibility
    gom   GObject to SQLite object mapper
    gol   Command-line utility for creating and managing Geographic Object Libraries
    goa   Design-based APIs and microservices in Go
    ego   Run Linux desktop applications under a different local user
    wego  Weather app for the terminal

    Showing 10 of 4772 results. Use `flox search go --all` to see the full list.

    Use 'flox show <package>' to see available versions
    ```

=== "Rust"

    Let's do a search for `rust` and see what we get:
    ```
    my_project $ flox search rust
    rustc    Safe, concurrent, practical language (wrapper script)
    irust    Cross Platform Rust Repl
    thrust   Chromium-based cross-platform / cross-language application framework
    rustus   TUS protocol implementation in Rust
    rustup   Rust toolchain installer
    rustic   fast, encrypted, deduplicated backups powered by pure Rust
    mrustc   Mutabah's Rust Compiler
    rustfmt  Tool for formatting Rust code according to style guidelines
    rustcat  Port listener and reverse shell
    ht-rust  Friendly and fast tool for sending HTTP requests

    Showing 10 of 810 results. Use `flox search rust --all` to see the full list.

    Use 'flox show <package>' to see available versions

    Related search results for 'cargo':
    cargo     Downloads your Rust project's dependencies and builds your project
    cargo-c   Cargo subcommand to build and install C-ABI compatible dynamic and static libraries
    cargo-ui  GUI for Cargo
    ```

    You'll notice that there's not a `rust` package!
    The Rust toolchain is unbundled in the Flox Catalog,
    so you'll instead want `rustc`, `cargo`, etc.
    For more details about setting up a Rust environment,
    see the [Rust cookbook page][rust-cookbook].

---

You'll notice that each search output contains a line like
```
Showing 10 of 4772 results. Use `flox search go --all` to see the full list.
```
You can use the `--all` flag to see the full list of results.

Another thing you'll notice is that these listings don't contain any version
information.
There's a separate command for that.
Let's see which Node.js versions are in the Flox Catalog via
[`flox show`][show]:

```
my_project $ flox show nodejs
nodejs - Event-driven I/O framework for the V8 JavaScript engine
    nodejs@20.17.0
    nodejs@20.16.0
    nodejs@20.15.1
    nodejs@20.14.0
    nodejs@20.12.2
    nodejs@20.11.1
    nodejs@20.11.0
    nodejs@20.10.0
    nodejs@18.18.2
    nodejs@18.18.0
    nodejs@18.17.1
    nodejs@18.17.0
    nodejs@18.16.1
    nodejs@18.16.0
    ...
    nodejs@14.17.0
    nodejs@14.16.1 (aarch64-linux, x86_64-darwin, x86_64-linux only)
    nodejs@14.16.0 (aarch64-linux, x86_64-darwin, x86_64-linux only)
    nodejs@14.15.5 (aarch64-linux, x86_64-darwin, x86_64-linux only)
    nodejs@14.15.4 (aarch64-linux, x86_64-darwin, x86_64-linux only)
    nodejs@14.15.3 (aarch64-linux, x86_64-darwin, x86_64-linux only)
```

The output is truncated for brevity,
but this output is showing another important feature:
packages in the Flox Catalog know which systems they're compatible with,
so you have safeguards against accidentally installing packages to your
environment that won't work on some of the systems you're interested in.
Note that you can still include different packages on different systems,
you just need to be intentional about it.
See the [multi-arch environments tutorial][multi-arch] for more details.

## Install dependencies

Next you'll install your dependencies via [`flox install`][install].
This transactionally builds your environment with the new packages so that
it's never left in a broken state.
The packages in your environment aren't available until you activate the
environment,
which we'll do in the next step,
but this means that the packages in a Flox environment don't get in your way
when you aren't using an environment.

```
my_project $ flox install go
```

You can also install specific versions at the command line using semver syntax:

```
my_project $ flox install go@1.22.6
```

## Activate the environment

In order to use the packages in the environment you need to _activate_ it
via [`flox activate`][activate].
This puts you into a subshell with various environment variables set
e.g. `PATH`, `CPATH`, `PKG_CONFIG_PATH`, `PYTHONPATH`, etc in such a way that
all of the packages in your environment should be available.

For instance, if you installed `go` 1.22.6 above,
activating your environment would look something like this:

```
my_project $ go version
fish: Unknown command: go

my_project $ flox activate
✅ You are now using the environment 'my_project'.
To stop using this environment, type 'exit'

flox [my_project] my_project $ go version
go version go1.22.6 darwin/arm64
```

When you activate the environment you can see that `flox [my_project]` is
prepended to your prompt so that you can see that you're inside the
environment.
If you have more than one environment activated (you can stack them!) this
prompt will show a list of the active environments.
Whether to show this prompt is configurable, see [`flox config`][config]
for details.
Note that in some cases the prompt modification may get overwritten by
customizations made to your shell prompt,
but in general a custom shell prompt will still show the Flox portion of the
prompt.

At this point your environment is ready to use,
but there's more to Flox environments than just installing packages.
The next few sections will show you how you can use [`flox edit`][edit]
to add environment variables, shell hooks, and services.

## Set environment variables

Say `my_project` requires some environment variables to be set
(a port, a URL, etc).
You can make environment variables with static values available inside the
environment by editing the `[vars]` section of your [manifest][manifest].

Up until this point we've only used the imperative, package manager-like
commands provided by Flox,
but many of these commands make edits to the `.flox/env/manifest.toml` file,
which is a declarative configuration file for your environment.
This is why it makes sense to keep your `.flox` directory stored alongside your
source code:
the configuration for your environment can be tracked in source control just
like your source code.

A manifest for an empty environment looks like this:
```toml
version = 1

[install]

[vars]

[hook]

[profile]

[services]

[options]
systems = ["aarch64-darwin", "x86_64-darwin", "aarch64-linux", "x86_64-linux"]
```

The packages we previously installed will be listed under the `[install]`
table.
You can explore your own manifest with the `flox edit` command.

Now let's add any environment variables you need via the `flox edit` command.
This opens the `manifest.toml` file in an editor so that you can manually
edit your environment configuration.
In order to set a variable `VAR` to the value `VALUE`,
you would edit the `[vars]` section to look like this:
```toml
[vars]
VAR = "VALUE"
```

Now is a good opportunity to edit your own manifest and add any static
environment variables your environment needs.
In the next step you'll see how to add environment variables that must be
computed dynamically e.g. from other environment variables.

## Add shell hooks

When activating an environment you may need to perform some kind of
initialization,
like creating a data directory or computing the value of an environment
variable.
Flox allows you to specify shell scripts to execute as part of activation for
performing this initialization.

Since Flox puts you into a subshell (of whatever shell you normally use),
which shell you're using may be different from a coworker's shell,
but you still want to initialize the environment in a consistent way.
However, you may also want to add shell aliases or source a shell-specific file
as part of activating your environment.

You can meet both of these needs with Flox.
The `hook.on-activate` script is always sourced into a Bash shell,
so initialization performed here is handled consistently no matter what shell
you or your coworkers use.
The scripts in the `[profile]` are always sourced into your shell _after_
`hook.on-activate` has run so you can provide aliases or source shell-specific
files (a Python virtual environment's `activate.sh` or `activate.fish` script
for example).

For more in-depth information on how the `[hook]` and `[profile]` sections work
see the [manifest reference page][manifest].
For now, this is how you would add a couple of shell hook scripts:
```toml
[hook]
on-activate = '''
  # Create a data directory if it doesn't already exist
  if [ ! -d data_dir ]; then
    mkdir data_dir
  fi
'''

[profile]
common = '''
  # This is sourced by *all* user's shells
  echo "Hello from all shells"
'''
bash = '''
  # Only sourced by Bash shells
  echo "Hello from Bash"
'''
```

A user activating this environment in a Bash shell would see this printed:
```
Hello from all shells
Hello from Bash
```
whereas a user activating from any other supported shell would see this:
```
Hello from all shells
```
The currently supported shells are `bash`, `zsh`, `fish`, and `tcsh`.

## Add services

It's common to need some other programs running in the background during
development,
such as a web server or a database.
Flox has first-class support for services like this via the `[services]`
section of the manifest.

Say you're working on a documentation site built using the `mkdocs` framework
and want to see a live preview of the documentation you're writing.
Adding a service for this is very easy:
```toml
[services.docs]
command = "mkdocs serve"
```

This creates a service called `docs` that starts the development server for
`mkdocs`.

You can automatically start services when you activate an environment via the
`flox activate --start-services` flag.
If you're already inside an environment that's been activated you can call
`flox services start`.
See the [services guide][services] for more details on how to work with services
in your Flox environment.

## But wait, there's more!

This was a quick introduction to some of the headlining features in Flox,
but we haven't covered some of the other awesome features.

You can push an environment to FloxHub via the [`flox push`][push] command,
at which point it can be shared with other people or other machines.
This also allows you to make environment templates that can be used as starting
points for projects e.g. a Rust environment that you [`flox pull`][pull] into
any new Rust project that you start.

You activate an environment stored on FloxHub via the `flox activate --remote`
flag.

Another interesting feature is the ability to stack multiple Flox environments!
Suppose you're working in a monorepo that contains both the front end and back
end for a website.
The front end and back end can both have their own environments,
and you would only need to activate one or the other depending on which part of
the site you're working on.
However, when you want to work across both sides of the site
(e.g. to update the provider and consumer of an API endpoint)
you can activate _both_ environments to do that work.

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } Try [**creating your first environment**][create_guide].

- :simple-readme:{ .flox-purple .flox-heart } Learn how to [**share and reuse** environments][share_guide].

- :simple-readme:{ .flox-purple .flox-heart } See **all the possibilities** for
[configuring your environment][manifest].

[install_flox]: ./install-flox.md
[create_guide]: ./tutorials/creating-environments.md
[share_guide]: ./tutorials/sharing-environments.md
[init]: ./reference/command-reference/flox-init.md
[search]: ./reference/command-reference/flox-search.md
[show]: ./reference/command-reference/flox-show.md
[catalog]: ./concepts/packages-and-catalog.md
[install]: ./reference/command-reference/flox-install.md
[activate]: ./reference/command-reference/flox-activate.md
[edit]: ./reference/command-reference/flox-edit.md
[push]: ./reference/command-reference/flox-push.md
[pull]: ./reference/command-reference/flox-pull.md
[delete]: ./reference/command-reference/flox-delete.md
[list]: ./reference/command-reference/flox-list.md
[manifest]: ./reference/command-reference/manifest.toml.md
[rust-cookbook]: ./cookbook/languages/rust.md
[multi-arch]: ./tutorials/multi-arch-environments.md
[config]: ./reference/command-reference/flox-config.md
[services]: ./concepts/services.md
