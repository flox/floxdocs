---
title: flox uninstall
description: Command reference for the `flox uninstall` command.
---

# `flox uninstall` command

## NAME

flox-uninstall - remove packages from an environment

## SYNOPSIS

    flox [<general options>] (uninstall|rm)
         [-d=<path> | -r=<owner/name>]
         <packages>

## DESCRIPTION

Uninstall packages from an environment.

Just like package installation, package uninstallation is transactional.
See [`flox-install(1)`](./flox-install.md) for more details on
transactions. Requesting to uninstall multiple packages where at least
one of them was not previously installed will cause the transaction to
fail and no packages will be uninstalled.

## OPTIONS

### Remove Options

`<packages>`  
The install IDs or package paths of the packages to remove. If the
manifest contains both an install ID and a package with matching package
path, the install ID takes precedence. If the same package path is
installed under different install IDs, an error is returned. A package
path can optionally contain the original version constraint.

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
