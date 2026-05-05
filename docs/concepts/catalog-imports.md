---
title: "Catalog imports"
description: Import packages from external catalogs for Nix expression builds
---

## Overview

Catalog imports allow your Nix expression builds to depend on
packages provided by external sources: remote Git repositories
or FloxHub users and organizations that publish reusable packages.

Rather than vendoring dependencies or using Nix flake inputs
directly, you declare catalogs in a configuration file and
access their packages via the `catalogs` argument in your
expressions. This keeps your build inputs explicit, lockable,
and reproducible.

Catalog imports extend [Nix expression builds][nix-expression-builds].
You should be familiar with defining packages in `.flox/pkgs/`
before using catalog imports.

## Configuring catalogs

Catalog imports use a two-file system:

- **`.flox/nix-builds.toml`** — the user-authored configuration
  file where you declare which catalogs to use.
- **`.flox/nix-builds.lock`** — a generated lockfile that pins
  each catalog to a specific revision for reproducibility.

Both files should be committed to version control. The TOML file
is authored by hand; the lockfile is generated and updated by
the `flox build update-catalogs` command.

## Source-ref (Git) catalogs

A Git catalog points at a remote repository that contains Flox
package definitions (a `.flox/pkgs/` directory). Declare one in
your `nix-builds.toml` under the `[catalogs]` section:

```{ .toml .copy title=".flox/nix-builds.toml" }
version = 1

[catalogs.my-packages]
type = "git"
url = "https://github.com/flox/flox-build-examples"
```

As a shorthand, you can provide a single `url` field using Nix
source reference syntax (the `git+` prefix encodes the type):

```{ .toml .copy title=".flox/nix-builds.toml" }
version = 1

[catalogs.my-packages]
url = "git+https://github.com/flox/flox-build-examples"
```

You can also use TOML dotted key syntax under a `[catalogs]`
header for simple cases:

```{ .toml .copy title=".flox/nix-builds.toml" }
version = 1

[catalogs]
my-packages.type = "git"
my-packages.url = "https://github.com/flox/flox-build-examples"
```

### Optional fields

| Field | Description |
| ----- | ----------- |
| `ref` | Git ref to track (branch, tag). Defaults to the repository's default branch. |
| `dir` | Subdirectory containing the `.flox/pkgs/` tree. Useful for monorepos. |

For example, to point at a subdirectory within a monorepo:

```{ .toml .copy title=".flox/nix-builds.toml" }
version = 1

[catalogs.flox-demo]
type = "git"
url = "https://github.com/flox/flox-build-examples"
dir = "quotes-app-rust"
```

## FloxHub catalogs

A FloxHub catalog references packages published to FloxHub via
[`flox publish`][publishing]. The catalog name corresponds to
the FloxHub user or organization that published them.

```{ .toml .copy title=".flox/nix-builds.toml" }
version = 1

[catalogs.ysndr]
type = "floxhub"
```

Or with dotted key syntax:

```{ .toml .copy title=".flox/nix-builds.toml" }
version = 1

[catalogs]
ysndr.type = "floxhub"
```

Public catalogs work without authentication. Private catalogs
(those published by an organization with restricted access)
require you to authenticate first with `flox auth login`.

## Using catalogs in expressions

Once catalogs are declared in `nix-builds.toml` and the lockfile
is generated, you access imported packages through the `catalogs`
argument in your Nix expressions.

!!! important
    The argument name must be `catalogs` (plural). Using
    `catalog` (singular) will not work.

The access pattern is:

```{ .nix .copy }
catalogs.<catalog-name>.<package-name>
```

For example, an expression that uses a package from a catalog:

```{ .nix .copy title=".flox/pkgs/demo.nix" }
{ catalogs }:

catalogs.flox-demo.quotes-app-rust-nix
```

The `catalogs` argument can be combined with other arguments
from nixpkgs:

```{ .nix .copy title=".flox/pkgs/my-app.nix" }
{ catalogs, rustPlatform, lib }:

rustPlatform.buildRustPackage {
  pname = "my-app";
  version = "0.1.0";
  src = ../../.;
  cargoLock.lockFile = ../../Cargo.lock;
  buildInputs = [ catalogs.shared-libs.common-utils ];
  meta.license = lib.licenses.mit;
}
```

## Updating catalog locks

Before you can build with catalog imports, you must generate the
lockfile. Run:

```{ .sh .copy }
flox build update-catalogs
```

This resolves each catalog declaration in `nix-builds.toml` and
writes the pinned revisions to `nix-builds.lock`.

Re-run this command whenever you:

- Add or change a catalog entry in `nix-builds.toml`
- Want to pick up newer versions of packages from a catalog

After updating, commit both `.flox/nix-builds.toml` and
`.flox/nix-builds.lock` to version control.

!!! note
    If you run `flox build` without first generating or updating
    the lockfile, the build will fail with an error indicating
    that catalogs have not been resolved.

## Examples

### Example: Git catalog

This example imports a Rust application from the
[flox-build-examples](https://github.com/flox/flox-build-examples)
repository.

**1. Declare the catalog:**

```{ .toml .copy title=".flox/nix-builds.toml" }
version = 1

[catalogs.flox-demo]
type = "git"
url = "https://github.com/flox/flox-build-examples"
dir = "quotes-app-rust"
```

**2. Write an expression that uses it:**

```{ .nix .copy title=".flox/pkgs/demo.nix" }
{ catalogs }:

catalogs.flox-demo.quotes-app-rust-nix
```

**3. Update the lockfile and build:**

```{ .sh .copy }
flox build update-catalogs
flox build demo
```

### Example: FloxHub catalog

This example uses a package published to FloxHub by the user
`ysndr`.

**1. Declare the catalog:**

```{ .toml .copy title=".flox/nix-builds.toml" }
version = 1

[catalogs]
ysndr.type = "floxhub"
```

**2. Write an expression that uses it:**

```{ .nix .copy title=".flox/pkgs/demo.nix" }
{ catalogs }:

catalogs.ysndr.blub
```

**3. Update the lockfile and build:**

```{ .sh .copy }
flox build update-catalogs
flox build demo
```

### Example: Combining catalogs with nixpkgs

A realistic expression might use both catalog imports and
standard nixpkgs helpers:

```{ .nix .copy title=".flox/pkgs/my-tool.nix" }
{ catalogs, rustPlatform, lib }:

rustPlatform.buildRustPackage rec {
  pname = "my-tool";
  version = "0.1.0";

  src = ../../.;
  cargoLock.lockFile = "${src}/Cargo.lock";

  buildInputs = [
    catalogs.shared-libs.crypto-utils
  ];

  meta = with lib; {
    description = "A tool that uses shared crypto utilities";
    license = licenses.mit;
  };
}
```

Here `rustPlatform` and `lib` come from nixpkgs (as with any
standard Nix expression build), while `catalogs.shared-libs.crypto-utils`
is resolved from the declared catalog.

[nix-expression-builds]: ./nix-expression-builds.md
[publishing]: ./publishing.md
