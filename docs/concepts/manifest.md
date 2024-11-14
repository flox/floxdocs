---
title: What is an environment manifest?
description: Everything you need to know about the environment's manifest.
---

# What is an environment manifest?

Flox environments come with a **declarative manifest** in [TOML][toml_spec] format.
Combined with its lockfile, the manifest can reproduce the environment on another machine.

## Editing your environment's manifest

The manifest contains the following sections represented as [TOML][toml_spec] tables:

  - **[install]:** The packages installed to the environment.
  - **[vars]:** Environment variables for use in the activated environment.
  - **[hook]:** Bash script executed before passing control to the user's shell.
  - **[profile]:** Shell-specific scripts sourced by the user's shell.
  - **[services]:** Long-running programs you can start when you activate
  - **[options]:** Environment settings.

The manifest can be edited with [`flox edit`][flox_edit] which allows validation to run when saving changes. This interactive editing option is useful for quick edits or to troubleshoot issues.

### [install] section

The install section of the manifest is the core of the environment -- the packages that will be available inside of the environment. Packages installed with [`flox install`][flox_install] will automatically get added to the `[install]` table.

Installing `curl` via
[`flox install`](../reference/command-reference/flox-install.md)

``` console
$ flox install curl
```

results in the following manifest (view the manifest with
[`flox edit`](../reference/command-reference/flox-edit.md)):

``` toml
[install]
curl.pkg-path = "curl"
```

The line that's added to the manifest has the form
`<id>.pkg-path = "<pkg-path>"`.

#### Identifying packages by `pkg-path`
The Flox catalog contains a hierarchy of packages where some are at the top
level,
and others are contained under package sets.
The `pkg-path` is the location of the package within the catalog,
including the package sets that it may be nested under.
For instance,
`pip` is nested under `python3Packages`,
so its `pkg-path` is `python3Packages.pip`.
The `pkg-path` is also what's displayed in search results,
so you should be able to copy and paste a search result into your manifest
or use it in a [`flox install`](../reference/command-reference/flox-install.md)
command.

#### Specifying package versions

The manifest can **install packages by semantic version** (semver).
The package will only be installed if it has a semantic version that falls
within the filter provided via the `version` key.
You use the `@` character to join the package name with the version when using
the CLI.

Let's try installing `curl` with at least version 8.

```console
$ # quoting is necessary for search terms that contain '>' or '<'
$ flox install 'curl@>=8'
```

Notice that the manifest now contains a second line with the semantic version
filter.

```toml
[install]
curl.pkg-path = "curl"
curl.version = ">=8"
```

You may also request a specific version
Here is an example of installing `curl` version 8.1.1:

``` console
$ flox install curl@8.1.1
```

Notice that the version line now starts with `=`.
This is how you tell Flox to install exact versions or versions that don't
adhere to semantic versioning.

``` toml
[install]
curl.pkg-path = "curl"
curl.version = "=8.1.1"
```

#### Installing packages to package groups

Flox will try to install packages that have been known to work together by default.
This allows Flox to ensure maximum compatibility and has the benefit of keeping the environment as small as possible.
However, sometimes you may need software that varies in age: For example, `packageA` you want to be from last week while `packageB` you need to be a specific older version. In these cases, you may see Flox error saying the constraints are too tight. To resolve this, you can specify a separate collection of packages using their `pkg-group` attribute.

```toml
[install]
packageA.pkg-path = "packageA"

packageB.pkg-path = "packageB"
packageB.version = "some.old.version"
packageB.pkg-group = "backend" # (1)!
```

1. "backend" is an arbitrary name. Try naming your pkg-group matching the logical grouping.

`pkg-group` is also useful for ensuring maximum compatibility between packages.
In this example say you're developing a new machine learning library that
depends on the XGBoost ML library.
XGBoost links against the popular Boost C++ collection of libraries,
and if we want to write our own C++ code that uses Boost,
we'll want to link against the same version of Boost that XGBoost is using.
We can ensure this happens by placing Boost and XGBoost in the same `pkg-group`.

```toml
[install]
boost.pkg-path = "boost"
boost.pkg-group = "my-ml-lib"
xgboost.pkg-path = "xgboost"
xgboost.pkg-group = "my-ml-lib"
```

#### System specific installations

Sometimes you may have a package that requires a specific CPU architecture or operating system.
To do this, include the system types supported for this package.
The systems specified for a package must be a subset of `options.systems`.

``` toml
[install]
gcc.pkg-path = "gcc-unwrapped"
gcc.systems = ["x86_64-linux", "aarch64-linux"]
```

#### Giving packages convenient names with `id`s
The `<id>` in `<id>.pkg-path = "<pkg-path>"` is the name by which we refer to a
package,
which may be distinct from the `pkg-path` of the package.
By default the `id` is inferred from the `pkg-path`,
but you may explicitly set the `id` during installation with the `--id` flag.
This allows you to provide more convenient names for package in your manifest.


### [vars] section

The `[vars]` section of the manifest allows for environment variables to be set
in the activated environment.
These variables are also made available to the scripts in the `[hook]` and
`[profile]` sections.

In the below example, `messsage` and `message2` are set, used in the
`profile.common` script to generate `greeting`, which is then used in the
`hook.on-activate` script to echo the final variable:

``` toml
[vars]
message = "Howdy"
message2 = "partner"

[hook]
on-activate = """
    export greeting="$message $message2"
"""

[profile]
common = """
    cowsay "$greeting" >&2;
"""
```

### [hook] section

The `on-activate` script in the `[hook]` section is useful for performing
initialization in a predictable Bash shell environment.

#### `on-activate`

The `on-activate` script is sourced from a **bash** shell,
and it can be useful for spawning processes, dynamically setting environment
variables, and creating files and directories to be used by the subsequent
profile scripts, commands, and shells.

Hook scripts inherit environment variables set in the `[vars]` section,
and variables set here will in turn be inherited by the `[profile]` scripts
described below.

Any output written to `stdout` in a hook script is redirected to `stderr` to
avoid it being mixed with the output of profile section scripts that write to
`stdout` for "in-place" activations.

```toml
[hook]
on-activate = """
    # Interact with the tty as you would in any script
    echo "Starting up $FLOX_ENV_DESCRIPTION environment ..."
    read -e -p "Favourite colour or favorite color? " value

    # Set variables, create files and directories
    venv_dir="$(mktemp -d)"
    export venv_dir

    # Perform initialization steps, e.g. create a python venv
    python -m venv "$venv_dir"

    # Invoke apps that configure the environment via stdout
    eval "$(ssh-agent)"
"""
```

The `on-activate` script is not re-run when activations are nested.
A nested activation can occur when an environment is already active and either
`eval "$(flox activate)"` or `flox activate -- CMD` is run.
In this scenario, `on-activate` is not re-run.
Currently, environment variables set by the first run of the `on-activate`
script are captured and then later set by the nested activation,
but this behavior may change.

It is best to write hooks defensively, assuming the user is using the
environment from any directory on their machine.

### [profile] section

Scripts defined in the `[profile]` section are sourced by *your shell* and
inherit environment variables set in the `[vars]` section and by the `[hook]`
scripts.
The `profile.common` script is sourced for every shell,
and special care should be taken to ensure compatibility with all shells.
The `profile.<shell>` scripts are then sourced *after* `profile.common` by the
corresponding shell.

These scripts are useful for performing shell-specific customizations such as
setting aliases or configuring the prompt.

```toml
[profile]
common = """
    echo "it's gettin' flox in here"
"""
bash = """
    source $venv_dir/bin/activate
    alias foo="echo bar"
    set -o vi
"""
zsh = """
    source $venv_dir/bin/activate
    alias foo="echo bar"
    bindkey -v
"""
```

Profile scripts are re-run for nested activations.
A nested activation can occur when an environment is already active and either
`eval "$(flox activate)"` or `flox activate -- CMD` is run.
In this scenario, profile scripts are run a second time.
Re-running profile scripts allows aliases to be set in subshells that inherit
from a parent shell with an already active environment.

### [options] section

The options section of the manifest allows for setting configuration around system
types.
Environments must specify all the systems that they are meant to be used on.

``` toml
[options]
systems = ["x86_64-linux", "aarch64-linux"]
```

### [services] section

The `[services]` section is where you define services that you want to
configure and run as part of your environment.
This could be a local version of a web server or database that your
application would connect to in production.
It could also be a program that live-reloads a website while you're working
on its CSS.

In order to start these services you would use the
`flox activate --start-services` command to start services while activating the
environment,
or the `flox services start` command to start services if you've already
activated the environment.
If you make edits to an environment after activating and you want your services
to pick up the edits,
you can run the `flox services restart` command.

To define a service you add a new entry to the `services` table in the manifest:
```toml
[services.database]
command = "postgres start"
vars.PGUSER = "myuser"
vars.PGPASSWORD = "super-secret"
vars.PGDATABASE = "mydb"
vars.PGPORT = "9001"
```

This entry creates a service called `database` that starts a PostgreSQL
database,
and configures it through service-specific environment variables.
The `command` field specifies a command to run (interpreted by Bash) to start
the service.
The `vars` set as part of this definition are only set for the service,
and aren't visible to other services or to your shell.

See [`manifest.toml`](../reference/command-reference/manifest.toml.md) for more
details on the `[service]` section of the manifest.

[toml_spec]: https://toml.io/en/v1.0.0
[flox_init]: ../reference/command-reference/flox-init.md
[flox_edit]: ../reference/command-reference/flox-edit.md
[flox_install]: ../reference/command-reference/flox-install.md
[flox_activate]: ../reference/command-reference/flox-activate.md
