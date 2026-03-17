---
title: Using a newer version of a package
description: >
  Override a package version in the Flox Catalog
  to get a newer release before it's available upstream.
---

# Using a newer version of a package

The Flox Catalog tracks [nixpkgs][nixpkgs], which means there can be a
short delay between an upstream release and its availability in
the catalog.
If you need a newer version right away, you can **override** the
existing package to point at the new release, then build and
publish it so the updated version is available everywhere.

This tutorial walks through the full workflow using
[Nix expression builds][nix-expression-builds].

## Scenario

Imagine the Flox Catalog currently provides `hello` version
2.12.1, but you need version 2.12.2.
Rather than waiting for the catalog to catch up, you'll
override the package to use the newer release.

## Create an environment

Let's start by creating a fresh environment for our override:

```text
$ mkdir hello-override && cd hello-override
$ flox init
⚡︎ Created environment 'hello-override' (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
  $ flox edit                <- Add environment variables and shell hooks
  $ flox push                <- Use the environment from other machines or
                                share it with someone on FloxHub
```

## Write the override

Create a Nix expression that takes the existing `hello` package
and overrides its `version` and `src` attributes:

```{ .bash .copy }
mkdir -p .flox/pkgs/hello
```

```{ .nix .copy title=".flox/pkgs/hello/default.nix" }
{ hello, fetchurl }:

hello.overrideAttrs (finalAttrs: _oldAttrs: {
  version = "2.12.2";
  src = fetchurl {
    url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
    hash = "";
  };
})
```

!!! note

    The `hash` is set to an empty string because we don't know
    the correct value yet. We'll let the build tell us in the
    next step.

## Set up Git

Nix expression builds require that all files in `.flox/pkgs/`
are tracked by Git.
Let's initialize a repository and add our files:

```{ .bash .copy }
git init
git add .
```

## Get the correct hash

Run `flox build` and it will fail with the expected hash:

```text
$ flox build
warning: found empty hash, assuming 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
Building hello-2.12.2 in Nix expression mode
...
error: hash mismatch in fixed-output derivation:
         specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
            got:    sha256-WpqZbcKSzCTc9BHO6H6S9qrluNE72caBm0x6nc4IGKs=
```

Copy the hash from the `got:` line and paste it into your
expression:

```{ .nix .copy title=".flox/pkgs/hello/default.nix" }
{ hello, fetchurl }:

hello.overrideAttrs (finalAttrs: _oldAttrs: {
  version = "2.12.2";
  src = fetchurl {
    url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
    hash = "sha256-WpqZbcKSzCTc9BHO6H6S9qrluNE72caBm0x6nc4IGKs=";
  };
})
```

## Build the package

Now run `flox build` again:

```text
$ flox build
Building hello-2.12.2 in Nix expression mode
...
Completed build of hello-2.12.2 in Nix expression mode

✨ Build completed successfully. Output created: ./result-hello
```

Verify it works:

```text
$ ./result-hello/bin/hello
Hello, world!
```

## Publish the package

The [`flox publish`][flox-publish] command requires a remote and
all tracked files committed and pushed.
Let's set that up and publish:

```text
$ git remote add origin "$PWD"
$ git add .
$ git commit -m "Add hello override"
$ git push origin main
$ flox publish hello
Building hello-2.12.2 in Nix expression mode
Completed build of hello-2.12.2 in Nix expression mode

✔ Package published successfully.

Use 'flox install myuser/hello' to install it.
```

!!! note

    Setting the remote to the local directory (`$PWD`) is a
    convenient shortcut for personal or test packages.
    For shared packages you'll want a proper remote
    (for example on GitHub).

The `flox publish` command performs a clean build from a
temporary checkout to ensure the package is fully reproducible.
See the [publishing concept][publishing-concept] page for more
details.

## Install from another environment

Once published, the overridden package is available in any Flox
environment.
Let's create a new environment and install it there:

```text
$ mkdir ~/myproject && cd ~/myproject
$ flox init
$ flox install myuser/hello
✔ 'myuser/hello' installed to environment 'myproject'
```

Verify you have the overridden version:

```text
$ flox activate -- hello --version
hello (GNU Hello) 2.12.2
```

## Next steps

This tutorial covered the simplest override — bumping a version
number.
The [Nix expression builds][nix-expression-builds] concept page
covers additional patterns:

- [Adding extensions][extensions-example] to an existing package
- [Applying patches][patches-example] to fix bugs
- [Vendoring a package][vendor-example] for deeper modifications

For a full walkthrough of the build and publish workflow,
including manifest builds, see the
[Building and publishing packages][build-and-publish] tutorial.

[nixpkgs]: https://github.com/NixOS/nixpkgs
[nix-expression-builds]: ../concepts/nix-expression-builds.md
[flox-publish]: ../man/flox-publish.md
[publishing-concept]: ../concepts/publishing.md
[extensions-example]: ../concepts/nix-expression-builds.md#example-extensions-of-an-existing-package
[patches-example]: ../concepts/nix-expression-builds.md#example-patches-to-an-existing-package
[vendor-example]: ../concepts/nix-expression-builds.md#example-vendor-an-existing-package
[build-and-publish]: ./build-and-publish.md
