---
title: flox show
description: Command reference for the `flox show` command.
---

# `flox show` command

## NAME

flox-show - show detailed information about a single package

## SYNOPSIS

    flox [<general-options>] show <pkg-path>

## DESCRIPTION

Show detailed information about a single package.

The default output includes the package description, name, and version.

### Package names

Packages are organized in a hierarchical structure such that certain
packages are found at the top level (e.g. `ripgrep`), and other packages
are found under package sets (e.g. `python310Packages.pip`). We call
this location within the catalog the “pkg-path”.

The pkg-path is searched when you execute a `flox search` command. The
pkg-path is what’s shown by `flox show`. Finally, the pkg-path appears
in your manifest after a `flox install`.

``` toml
[install]
ripgrep.pkg-path = "ripgrep"
pip.pkg-path = "python310Packages.pip"
```

## OPTIONS

### General Options

`-h`, `--help`  
Prints help information.

The following options can be passed when running any `flox` subcommand
but must be specified *before* the subcommand.

`-v`, `--verbose`  
Increase logging verbosity. Invoke multiple times for increasing detail.

`-q`, `--quiet`  
Silence logs except for errors.

### Show Options

`<pkg-path>`  
Package name to show details for.

## EXAMPLES:

Display detailed information about the `ripgrep` package:

    $ flox show ripgrep
    ripgrep - A utility that combines the usability of The Silver Searcher with the raw speed of grep
        ripgrep@13.0.0
        ripgrep@14.1.0

## SEE ALSO

[`flox-search(1)`](./flox-search.md),
[`flox-install(1)`](./flox-install.md)
