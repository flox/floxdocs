---
title: flox list
description: Command reference for the `flox list` command.
---

# `flox list` command

## NAME

flox-list - list packages installed in an environment

## SYNOPSIS

    flox [<general-options>] list
         [-d=<path> | -r=<owner/name>]
         [-e | -c | -n | -a]

## DESCRIPTION

List packages installed in an environment. The options `-n`, `-e`, and
`-a` exist to provide varying levels of detail in the output.

## OPTIONS

### List Options

`-e`, `--extended`  
Show the install ID, pkg-path, and version of each package (default).

`-c`, `--config`  
Show the raw contents of the manifest. When using composition, the
merged manifest will be shown without any commented lines.

`-n`, `--name`  
Show only the install ID of each package.

`-a`, `--all`  
Show all available package information including priority and license.

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

[`flox-install(1)`](./flox-install.md)
