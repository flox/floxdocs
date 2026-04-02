---
title: Selecting package outputs
description: Learn how to intentionally declare which parts of a package you want to install
---

# Selecting package outputs

Packages in the [Flox Catalog][catalog-and-pkgs] contain metadata about their origin, license, version, etc.
They _also_ contain metadata about the various "parts" of a package.
We call these "parts" of a package its "outputs".

Some packages only have one output, others have many.
For example, the `hello` package only has one output called `out` (the default in most cases).
The `curl` package, on the other hand, contains several outputs, one of which is OS-specific: `bin`, `dev`, `man`, `out`, `debug` (only available on Linux), and `devdoc`.

Which outputs exist for a given package and which outputs are installed by default is determined by the package maintainer in the upstream Nixpkgs repository.

In this tutorial you'll learn how to discover which outputs are available for a package, which outputs are installed by default, and how to specify precisely which outputs to install for a package.

## Why?

So why would you want to pick package outputs on your own?
Aren't the default outputs fine in most cases?

Yes, they are!
But _most_ cases is not the same as _all_ cases.
The ability to select package outputs allows you to tailor your environment to exactly what you need.

For example, prior to CLI version 1.10.0, you would get all of `curl`'s outputs.
That places 48 binaries in `$FLOX_ENV/bin`.
For CLI versions 1.10.0 and later you only get the default outputs.
That places 3 binaries in `$FLOX_ENV/bin`.
That's a big difference!

This can make the surface area of your environment smaller, but it can also make the _download size_ of your environment smaller.
For example, the difference between the default outputs and all outputs for `curl` is roughly 20MB.
That's not a _huge_ difference, but this is a relatively small package, and only a single package.

It's a different story once you start including very large packages like parts of the [CUDA Toolkit][cuda], which add up to several GB.

## Discovering outputs

The main way that you'll discover the outputs of a package is with the [`flox show`][flox-show] command.

Let's see what it looks like for the `hello` package:

```text
$ flox show hello
hello - Program that produces a familiar, friendly greeting
Catalog: nixpkgs
Latest:  hello@2.12.2
License: GPL-3.0-or-later
Outputs: out* (* installed by default)
Systems: aarch64-linux, aarch64-darwin, x86_64-darwin, x86_64-linux

Other versions:
    hello@2.12.2
    hello@2.12.1
    hello@2.12
    hello@2.10
```

Notice the line that starts with `Outputs:`.
This part of the description is a list of the outputs that the package defines.
The outputs that are installed by default are marked with an asterisk `*`.
In the case of `hello`, there's only one output (`out`) and it's installed by default, which you can tell because it's listed as `out*`.

Let's see what it looks like for a more complicated package like `curl`:

```text
$ flox show curl
curl - Command line tool for transferring files with URL syntax
Catalog: nixpkgs
Latest:  curl@8.18.0
License: curl
Outputs: bin*, dev, man*, out, debug, devdoc (* installed by default)
Systems: aarch64-linux, x86_64-darwin, aarch64-darwin, x86_64-linux

Other versions:
    curl@8.18.0
    curl@8.17.0
    curl@8.16.0
    curl@8.14.1
    curl@8.13.0
    curl@8.12.1
    curl@8.12.0
    curl@8.11.1
    curl@8.11.0
    curl@8.10.1
    ...(truncated for space)
```

As mentioned previously, `curl` has several outputs, with only `bin` and `man` being installed by default.

## Which output do I want?

Unfortunately, there are no hard rules for which outputs can exist or even when a package author should split the package into multiple outputs.
This is an idiosyncracy of where the Flox Catalog gets its packages from (Nixpkgs).

On the other hand, there are some relatively well adhered to conventions for the set of possible output names and what they contain:

- `bin`: executable programs
- `man`: manual pages
- `lib`: dynamic libraries
- `dev`: header files and/or tools needed during development
- `debug`: debug symbols for the executables and libraries in the package
- `out`: typically the "main" output or the only output

The `curl` package is one of these idiosyncratic cases because the `out` output (1) isn't installed by default, and (2) is where the `libcurl` dynamic library is placed rather than a `lib` output.

## Selecting outputs

Prior to version 1.10.0 of the Flox CLI, all outputs of a package were installed when a package was added to an environment.
As of CLI version 1.10.0 you can specify which outputs to install using a manifest with `schema-version` 1.10.0 or later (note that the `schema-version` field replaced the `version` field in CLI version 1.10.0).

The most flexible way to specify outputs is by setting the `outputs` field on a package in your manifest. The `outputs` field has three behaviors:

- When omitted, only the default outputs are installed
- When set to `"all"`, all outputs are installed
- When set to a list of strings (`["foo", "bar"]`), only those specific outputs are installed

```toml
schema-version = "1.10.0"

[install]
curl.pkg-path = "curl"
# Default: `outputs` is unspecified, so only the default outputs are installed

# Using this would install all of curl's outputs
# curl.outputs = "all"

# Using this would only install the "bin" output
# curl.outputs = [ "bin" ]
```

You can also specify which outputs to install via the [`flox install`][flox-install] command using the following syntax:

```{ .bash .copy }
flox install curl^bin,man,out
```

A comma-separated list after a `^` is treated as a list of outputs you'd like to install.
Note that for the moment this is only allowed when installing a new package.
In the future you will be able to install and uninstall specific outputs of existing packages.

## Conclusion

Hopefully you now have an understanding that packages consist of chunks called "outputs" and that you have the ability to select precisely which ones you want to include in an environment.

[catalog-and-pkgs]: ../concepts/packages-and-catalog.md
[flox-show]: ../man/flox-show.md
[flox-install]: ../man/flox-install.md
[flox-uninstall]: ../man/flox-uninstall.md
[cuda]: ./cuda.md
