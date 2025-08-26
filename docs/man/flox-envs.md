---
title: flox envs
description: Command reference for the `flox envs` command.
---

# `flox envs` command

## NAME

flox-envs - show active and available environments

## SYNOPSIS

    flox [<general options>] envs
         [--active]
         [--json]

## DESCRIPTION

This command can be used to list available environments on the local
machine. When one or more environments are active, the last activated
environment will be listed first and printed in **bold**.

Whenever an environment is used with any `flox` command it is registered
to a user specific global registry. `flox envs` will list all
environments known to it through the registry. Environments that are
present on the local system may not show up until they are used the
first time. Similarly, if an environment is changed (e.g. deleted and
replaced by an environment with different metadata), the change may not
show until the new environment is used.

## OPTIONS

### Edit Options

`--active`  
Show only active environments

`--json`  
Format the output as JSON

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

[`flox-init(1)`](./flox-init.md), [`flox-pull(1)`](./flox-pull.md),
[`flox-activate(1)`](./flox-activate.md)
