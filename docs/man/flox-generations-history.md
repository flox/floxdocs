---
title: flox generations history
description: Command reference for the `flox generations history` command.
---

# `flox generations history` command

## NAME

flox-generations-history - Show the change log for the current
environment

## SYNOPSIS

    flox [<general-options>] generations history
         [-d=<path> | -r=<owner/name>]

## DESCRIPTION

Show the change log for the current environment.

For environments pushed to FloxHub, every modification to the
environment creates a new generation of the environment. It’s also
possible to change the current generation by using
`flox generations switch` or `flox generations rollback`.

`flox generations history` prints what generation has been the current
generation over time.

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

[`flox-generations-list(1)`](./flox-generations-list.md)
[`flox-generations-rollback(1)`](./flox-generations-rollback.md)
[`flox-generations-switch(1)`](./flox-generations-switch.md)
