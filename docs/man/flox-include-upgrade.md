---
title: flox include upgrade
description: Command reference for the `flox include upgrade` command.
---

# `flox include upgrade` command

## NAME

flox-include-upgrade - upgrade an environment with latest changes to its
included environments

## SYNOPSIS

    flox [<general-options>] include upgrade
         [-d=<path> | -r=<owner/name>]
         [<included environment>]...

## DESCRIPTION

Get the latest contents of included environments and merge them with the
composing environment.

If the names of specific included environments are provided, only
changes for those environments will be fetched. If no names are
provided, changes will be fetched for all included environments.

## OPTIONS

`<included environment>`  
Name of included environment to check for changes

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

[`manifest-toml`(5)](./manifest.toml.md),
