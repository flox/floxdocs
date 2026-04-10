---
title: flox search
description: Command reference for the `flox search` command.
---

# `flox search` command

## NAME

flox-search - search for packages

## SYNOPSIS

    flox [<general options>] search
         [--json]
         [-a]
         <search-term>

## DESCRIPTION

Search for available packages.

A limited number of search results are reported by default for brevity.
The full result set can be returned via the `-a` flag.

Only the package name and description are shown by default. Structured
search results can be returned via the `--json` flag. More specific
information for a single package is available via the
[`flox-show(1)`](./flox-show.md) command.

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

### Fuzzy search

`flox search` uses a fuzzy search mechanism that tries to match either
some portion of the pkg-path or description.

## OPTIONS

### Search Options

`<search-term>`  
The package name to search for.

`--json`  
Display the search results in JSON format.

`-a`, `--all`  
Display all search results (default: at most 10).

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

[`flox-show(1)`](./flox-show.md)
