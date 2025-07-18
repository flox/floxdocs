---
title: "Nix expression builds"
description: Nix expression builds with Flox
---

See the [builds concept][builds-concept] page for an overview of the different types of builds and how to perform them.

## Overview

Nix expression builds are defined by creating files in the `.flox/pkgs/` directory of a Flox environment. These expressions are written in the Nix language, which is incredibly powerful and results in truly reproducible builds.

The environment that contains the builds doesn't need to have any packages installed because all of the build's dependencies are defined within the expression, but if there are any packages installed then Flox will attempt to produce a build that is compatible with any packages in the "toplevel" [package group][pkg-groups].

## Defining builds

Each build specified in the `.flox/pkgs/` directory corresponds to a different package with the name taken from a combination of the path and file names, for example:

| Path | Name |
| ---- | ---- |
| `.flox/pkgs/hello.nix`                       | `hello` |
| `.flox/pkgs/hello/default.nix`               | `hello` |
| `.flox/pkgs/hello/how/do/you/do/default.nix` | `hello.how.do.you.do` |

These names cannot conflict with [manifest builds][manifest-builds-concept] in the same environment and will result in an error if they do.

All of the files in the `.flox/pkgs` directory must be tracked by a Git repository (`git add`ed but not necessarily committed) which ensures that unnecessary cache files and secrets don't end up in your package.

## What can you build?

Nix provides a variety of helpers for common builds and language frameworks to help you package your own software:

* [Language support](https://nixos.org/manual/nixpkgs/stable/#chap-language-support)
* [Trivial builders](https://nixos.org/manual/nixpkgs/stable/#chap-trivial-builders)

You can also make modifications to existing packages that are already in the Flox Catalog.

### Example: Distributing a script

To distribute a simple shell script which has a dependency on existing packages:

```nix title=".flox/pkgs/my-ip.nix"
{writeShellApplication, curl}:

writeShellApplication {
  name = "my-ip";
  runtimeInputs = [ curl ];
  text = ''
    curl icanhazip.com
  '';
}
```

This will ensure that a known version of `bash` and `curl` are available to the package at runtime. It will also automatically add some error handling options (`errexit`, `nounset`, `pipefail`) and validate the script with `shellcheck`.

### Example: Building your own project

To build a Rust project that lives in the same repository as your Flox environment:

```nix title=".flox/pkgs/quotes-app-rust.nix"
{ rustPlatform, lib }:

rustPlatform.buildRustPackage rec {
  pname = "quotes-app-rust";
  version = "0.1.0";

  src = ../../.;
  cargoLock.lockFile = "${src}/Cargo.lock";

  meta = with lib; {
    description = "Quotes App written in Rust";
    license = licenses.mit;
  };
}
```

This will vendor dependencies from your `Cargo.lock` file, run `cargo build`, and package the resulting binary.

### Example: Building a third-party project

If there's an open source Go project that isn't already available in the Flox Catalog:

```nix title=".flox/pkgs/quotes-app-go.nix"
{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "quotes-app-go";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "flox";
    repo = "flox-manifest-build-examples";
    rev = "285aaa8334762f2006151b03208a51527ff762e9";
    hash = "sha256-4BACKTYqsq0ZHno1jXCta4761pv3rFhlSEpVRWltSqQ=";
  };
  sourceRoot = "${src.name}/${pname}";
  vendorHash = "sha256-8wYERVt3PIsKkarkwPu8Zy/Sdx43P6g2lz2xRfvTZ2E=";

  meta = with lib; {
    description = "Quotes App written in Go";
    license = licenses.mit;
  };
}
```

This will vendor dependencies from your `go.mod` file, run `go build`, and package the resulting binary.

### Example: Extensions of an existing package

If you want to use VS Code with some pre-installed extensions:

```nix title=".flox/pkgs/vscode-with-extensions.nix"
{vscode, vscode-utils, vscode-extensions, vscode-with-extensions}:

vscode-with-extensions.override {
  inherit vscode;

  vscodeExtensions = with vscode-extensions; [
    bbenoist.nix
    github.copilot
  ] ++ vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "flox";
      publisher = "flox";
      version = "0.0.2";
      hash = "sha256-wvRhPPSnCimpB1HEbAg7a0r9hFKzMZ/Z1vS+XVmviOM=";
    }
  ];
}
```

This will add the Nix, GitHub Copilot, and Flox extensions to the VS Code package.

### Example: Newer version of an existing package

If the latest version of a package isn't yet available in the Flox Catalog then you can often just override the `version` and `src` attributes of the existing package:

```nix title=".flox/pkgs/hello.nix"
{ hello, fetchurl }:

hello.overrideAttrs (finalAttrs: oldAttrs: {
  version = "2.12.2";
  src = fetchurl {
    url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
    hash = "sha256-WpqZbcKSzCTc9BHO6H6S9qrluNE72caBm0x6nc4IGKs=";
  };
})
```

### Example: Patches to an existing package

If you want to apply a patch, such as an unreleased bug fix, to an existing package:

```nix title=".flox/pkgs/hello-shouty/default.nix"
{ hello }:

hello.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or []) ++ [
    ./shouty.patch
  ];
  meta = oldAttrs.meta // {
    description = "A patched version of hello that shouts the default greeting.";
  };
})
```

Note that this expression is saved as `default.nix` in its own sub-directory so that we can version control the patch as a separate file.
This build also defines tests so they have to be modified too:

```diff title="./flox/pkgs/hello-shouty/shouty.patch"
--- hello-2.12.2/src/hello.c  2025-05-19  12:49:04
+++ hello-patched/src/hello.c 2025-07-04 10:33:57
@@ -145,7 +145,7 @@
 #endif
 
   /* Having initialized gettext, get the default message. */
-  greeting_msg = _("Hello, world!");
+  greeting_msg = _("HELLO, WORLD!");
 
   /* Even exiting has subtleties.  On exit, if any writes failed, change
      the exit status.  The /dev/full device on GNU/Linux can be used for
diff -ru hello-2.12.2/tests/hello-1 hello-patched/tests/hello-1
--- hello-2.12.2/tests/hello-1  2025-05-19 12:49:04
+++ hello-patched/tests/hello-1 2025-07-04 10:48:38
@@ -21,7 +21,7 @@
 
 tmpfiles="hello-test1.ok"
 cat <<EOF > hello-test1.ok
-Hello, world!
+HELLO, WORLD!
 EOF
 
 tmpfiles="$tmpfiles hello-test1.out"
```

### Example: Vendor an existing package

Typically you would only override specific attributes of an existing package, which allows you to continue benefiting from upstream changes and surface failures if there are any conflicts, but if you want to copy a package to make more fundamental changes or because it's being removed upstream:

```sh
EDITOR=cat \
  nix --extra-experimental-features "nix-command flakes" \
  edit 'nixpkgs#hello' \
  > .flox/pkgs/hello.nix
```

This will extract the expression for the `hello` package in `nixpkgs` and save the contents to file which can then be modified.

## Tips

### Generating hashes

Expressions that fetch external dependencies will often specify hashes to ensure that they are reproducible, trusted, and speed up cached steps. The hash should be changed whenever you change a `src` or `url` otherwise the sources may not be fetched again or they will fail the validation check.

If you don't have a way of verifying the current hash and you trust the source then you can specify an empty string value:

```nix
  src = fetchurl {
    url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
    hash = "";
  };
```

Then perform a `flox build` and take the correct value from the error message:

```
warning: found empty hash, assuming 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
Building hello-2.12.2 in Nix expression mode
these 2 derivations will be built:
  /nix/store/srm7s6pyckifs52ikyfasf6bqkk2c5ls-hello-2.12.2.tar.gz.drv
  /nix/store/3d9n2f5pg2s4y3p46awmsp46fxpdfkg6-hello-2.12.2.drv
building '/nix/store/srm7s6pyckifs52ikyfasf6bqkk2c5ls-hello-2.12.2.tar.gz.drv'...
hello> 
hello> trying https://ftpmirror.gnu.org/hello/hello-2.12.2.tar.gz
hello>   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
hello>                                  Dload  Upload   Total   Spent    Left  Speed
hello>   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
hello> 100 1141k  100 1141k    0     0   906k      0  0:00:01  0:00:01 --:--:-- 2218k
error: hash mismatch in fixed-output derivation '/nix/store/srm7s6pyckifs52ikyfasf6bqkk2c5ls-hello-2.12.2.tar.gz.drv':
         specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
            got:    sha256-WpqZbcKSzCTc9BHO6H6S9qrluNE72caBm0x6nc4IGKs=
```

[builds-concept]: ./builds.md
[manifest-builds-concept]: ./manifest-builds.md
[pkg-groups]: ../reference/command-reference/manifest.toml.md#package-descriptors
