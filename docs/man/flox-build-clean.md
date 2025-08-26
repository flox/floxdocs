---
title: flox build clean
description: Command reference for the `flox build clean` command.
---

# `flox build clean` command

## NAME

flox-build-clean - Clean the build directory

## SYNOPSIS

    flox [<general-options>] build clean
         [-d=<path>]
         [<package>]...

## DESCRIPTION

Remove the build artifacts for `<package>` from the environment in
`<path>`. Without `<package>` specified clean up all packages and
build-related temporary data.

## OPTIONS

`<package>`  
The package(s) to clean. Possible values are all keys under the `build`
attribute in the environment’s `manifest.toml`. If omitted, will clean
all build related data.

### Environment Options

If no environment is specified for an environment command, the
environment in the current directory or the active environment that was
last activated is used.

`-d`, `--dir`  
Path containing a .flox/ directory.

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

[`flox-build(1)`](./flox-build.md)
[`manifest.toml(5)`](./manifest.toml.md)
