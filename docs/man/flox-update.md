---
title: flox update
description: Command reference for the `flox update` command.
---

# `flox update` command
---
title: flox update
description: Command reference for the `flox update` command.
---

# `flox update` command
---
title: flox update
description: Command reference for the `flox update` command.
---

# `flox update` command

> **Warning:** This command is **deprecated** and no longer supported

## NAME

flox-update - update the global base catalog or an environment’s base
catalog

## SYNOPSIS

    flox [<general-options>] update
         [--global | (-d=<path> | -r=<owner>/<name>)]

## DESCRIPTION

Update an environment’s base catalog, or update the global base catalog
if `--global` is specified.

The base catalog is a collection of packages used by various Flox
subcommands.

The global base catalog provides packages for
[`flox-search(1)`](./flox-search.md) and
[`flox-show(1)`](./flox-show.md) when not using an environment, and it
is used to initialize an environment’s base catalog.

An environment’s base catalog provides packages for
[`flox-search(1)`](./flox-search.md) and
[`flox-show(1)`](./flox-show.md) when using that environment, and it
provides packages for [`flox-install(1)`](./flox-install.md) and
[`flox-upgrade(1)`](./flox-upgrade.md).

Note that updating an environment’s base catalog and upgrading packages
are two separate options. Upgrading packages will usually require
running an update command followed by a
[`flox-upgrade`](./flox-upgrade.md).

## OPTIONS

### Update Options

`--global`  
Update the global base catalog

### Environment Options

If no environment is specified for an environment command, the
environment in the current directory or the active environment that was
last activated is used.

`-d`, `--dir`  
Path containing a .flox/ directory.

`-r`, `--remote`  
A remote environment on FloxHub, specified in the form `<owner>/<name>`.

### General Options

`-h`, `--help`  
Prints help information.

The following options can be passed when running any `flox` subcommand
but must be specified *before* the subcommand.

`-v`, `--verbose`  
Increase logging verbosity. Invoke multiple times for increasing detail.

`-q`, `--quiet`  
Silence logs except for errors.

## SEE ALSO

[`flox-upgrade(1)`](./flox-upgrade.md)
