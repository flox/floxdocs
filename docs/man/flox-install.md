---
title: flox install
description: Command reference for the `flox install` command.
---

# `flox install` command

## NAME

flox-install - install packages to an environment

## SYNOPSIS

    flox [<general options>] install
         [-i <id>] <package>
         [[-i <id>] <package>] ...

## DESCRIPTION

Install packages to an environment.

Package installation is transactional. During an installation attempt
the environment is built in order to validate that the environment isn’t
broken (for example, in rare cases packages may provide files that
conflict). If building the environment fails, including any of the
constituent packages, the attempt is discarded and the environment is
unmodified. If the build succeeds, the environment is atomically
updated.

If a requested package is already installed, nothing is done. If
multiple packages are requested and some of them are already installed,
only the new packages are installed and the transaction will still
succeed as long as the build succeeds.

You may also specify packages to be installed via
[`flox-edit(1)`](./flox-edit.md), which allows specifying a variety of
options for package installation. See
[`manifest-toml(1)`](./manifest.toml.md) for more details on the
available options.

### Install ID

The name of a package as it exists in the manifest is referred to as the
“install ID”. This ID is separate from the pkg-path and provides a
shorthand for packages with long names such as `python310Packages.pip`.
Install IDs also provide a way to give packages more semantically
meaningful, convenient, or aesthetically pleasing names in the manifest
(e.g. `node21` instead of `nodejs_21`). When not explicitly provided,
the install ID is inferred based on the pkg-path. For pkg-paths that
consist of a single attribute (e.g. `ripgrep`) the install ID is set to
that attribute. For pkg-paths that consist of multiple attributes
(e.g. `python310Packages.pip`) the install ID is set to the last
attribute in the pkg-path (e.g. `pip`).

As an advanced feature, a Nix flake installable may be specified instead
of a pkg-path, and in this case the install ID is inferred from the
attribute path specified, or if no attribute path is provided, the
install ID is inferred from the flake reference.

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

### Install Options

`-i`, `--id`  
The install ID of the package as it will appear in the manifest

`<package>`  
The pkg-path of the package to install as shown by ‘flox search’ Append
`@<version>` to specify a version requirement.

Alternatively, an arbitrary Nix flake installable, or store path may be
specified. See [`manifest-toml(1)`](./manifest.toml.md) for more
details.

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

### SEE ALSO

[`flox-uninstall(1)`](./flox-uninstall.md),
[`flox-edit(1)`](./flox-edit.md),
[`manifest.toml(5)`](./manifest.toml.md)
