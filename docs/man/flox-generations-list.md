---
title: flox generations list
description: Command reference for the `flox generations list` command.
---

# `flox generations list` command

## NAME

flox-generations-list - show all environment generations that you can
switch to

## SYNOPSIS

    flox [<general-options>] generations list
         [-d=<path> | -r=<owner/name>]

## DESCRIPTION

Show all environment generations that you can switch to.

For environments pushed to FloxHub, every modification to the
environment creates a new generation of the environment.

`flox generations list` prints all generations of the environment,
including which generation is currently live.

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

[`flox-generations-history(1)`](./flox-generations-history.md)
[`flox-generations-rollback(1)`](./flox-generations-rollback.md)
[`flox-generations-switch(1)`](./flox-generations-switch.md)
