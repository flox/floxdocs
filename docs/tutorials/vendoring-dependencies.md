---
title: Vendoring unavailable dependencies
description: How to build packages when dependencies aren't available in the Flox Catalog or nixpkgs
---

# Vendoring unavailable dependencies

When building with Flox,
your dependencies come from different sources depending on which build type
you use:

- **[Manifest builds][manifest-builds-concept]** draw installed packages from
  the [Flox Catalog][catalog-concept]
- **[Nix expression builds][nix-expression-builds-concept]** draw packages from
  [nixpkgs][base-catalog-concept]

There are two distinct vendoring problems you may encounter,
and these call for different solutions.

### Sandbox vendoring vs. missing dependencies

**Sandbox vendoring** is when your dependencies exist in their language
ecosystem (Go modules, crates.io, npm) but a
[pure build][pure-builds-section] blocks network access,
preventing the build from downloading them.
The fix is a multi-stage build:
an impure first stage pre-fetches the dependencies,
and the pure second stage consumes them offline.
This is covered in the language guides
([Go][go-vendoring], [Rust][rust-vendoring], [Node.js][nodejs-vendoring]).

**Missing dependency vendoring** is when the dependency doesn't exist
in the Flox Catalog or nixpkgs at all.
A toolchain may be too new for nixpkgs to have packaged,
a tool may not be packaged for Nix yet,
or a pre-built binary may be the only practical distribution method.
No amount of network access helps here
because the package manager itself doesn't know about the dependency:
you need to bring it into the ecosystem yourself.

**This guide covers the second problem.**

## Manifest builds

Manifest builds install dependencies from the Flox Catalog
via the `[install]` section.
If a dependency isn't in the catalog,
you have several options.

### Provide the dependency as a Nix expression build

You can define missing dependencies as
[Nix expression builds][nix-expression-builds-concept]
in `.flox/pkgs/`
and install them into your environment alongside catalog packages.
Nix expression builds and manifest builds can coexist in the same environment,
so long as their package names don't conflict.

For example,
if your project needs a dependency that isn't in the Flox Catalog,
you can package a pre-built binary as a Nix expression:

```{ .nix .copy title=".flox/pkgs/my-custom-tool.nix" }
{ lib, stdenv, fetchurl, autoPatchelfHook }:

let
  sources = {
    x86_64-linux = {
      url = "https://example.com/releases/v1.0.0/my-custom-tool-linux-x64.tar.gz";
      hash = "";
    };
    aarch64-darwin = {
      url = "https://example.com/releases/v1.0.0/my-custom-tool-darwin-arm64.tar.gz";
      hash = "";
    };
  };

  platform = stdenv.hostPlatform.system;
  source = sources.${platform}
    or (throw "Unsupported platform: ${platform}");
in
stdenv.mkDerivation {
  pname = "my-custom-tool";
  version = "1.0.0";

  src = fetchurl {
    inherit (source) url hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src
    install -m755 my-custom-tool $out/bin/
  '';
}
```

After running `git add .flox/pkgs/my-custom-tool.nix`,
the dependeny is available via `flox build my-custom-tool`
and can be installed into your environment.

Use the [empty hash technique][nix-expression-hashes]
to determine the correct hash for each platform.

### Use a flake input

If the dependency is available as a Nix flake,
you can reference it directly in your manifest:

```toml
[install]
my-tool.flake = "github:owner/repo"
```

This installs the flake's default package into your environment,
making it available to your manifest builds.

### Download in an impure build stage

For manifest builds with `sandbox = "off"` (the default),
you can download dependencies directly in your build script:

```toml
[build.myproject]
command = '''
  # Download a tool not in the catalog
  curl -L -o custom-tool \
    https://example.com/releases/custom-tool-linux-x86_64
  chmod +x custom-tool
  export PATH="$PWD:$PATH"

  # Use it in the build
  custom-tool generate ./src
  mkdir -p $out/bin
  cp result $out/bin/myproject
'''
```

!!! warning "Warning"
    This approach only works with `sandbox = "off"` (the default).
    [Pure builds][pure-builds-section] on Linux do not have network access.
    If you need this dependency in a pure build,
    use a multi-stage pattern where the first stage downloads the tool
    impurely and the second stage builds with `sandbox = "pure"`:

    ```toml
    [build.myproject-tools]
    command = '''
      mkdir -p $out/bin
      curl -L -o $out/bin/custom-tool \
        https://example.com/releases/custom-tool-linux-x86_64
      chmod +x $out/bin/custom-tool
    '''

    [build.myproject]
    command = '''
      export PATH="${myproject-tools}/bin:$PATH"
      custom-tool generate ./src
      mkdir -p $out/bin
      cp result $out/bin/myproject
    '''
    sandbox = "pure"
    ```

## Nix expression builds

Nix expression builds draw all dependencies from nixpkgs
via function arguments.
When a dependency isn't available in nixpkgs
— or the version you need is too new —
you need to vendor it yourself.

### Override an existing package's version

If a package exists in nixpkgs but you need a newer version,
you can often override its `version` and `src` attributes:

```{ .nix .copy title=".flox/pkgs/my-tool.nix" }
{ my-tool, fetchurl }:

my-tool.overrideAttrs (finalAttrs: _oldAttrs: {
  version = "2.5.0";
  src = fetchurl {
    url = "https://example.com/releases/my-tool-${finalAttrs.version}.tar.gz";
    hash = "";
  };
})
```

This works well when the package's build process hasn't changed significantly
between versions.
See the [newer version example][nix-override-example]
in the Nix expression builds concept page for more details.

### Vendor a pre-built toolchain

When a toolchain version isn't in nixpkgs at all,
you can create a derivation that downloads pre-built binaries.
This is a common pattern for vendoring newer versions of Go, Node.js,
or other language runtimes.

Here is an example that vendors a specific Go version
with cross-platform support:

```{ .nix .copy title=".flox/pkgs/go_custom.nix" }
{ lib, stdenv, fetchurl }:

let
  version = "1.26.0";

  sources = {
    x86_64-linux = {
      url = "https://go.dev/dl/go${version}.linux-amd64.tar.gz";
      hash = "";
    };
    aarch64-linux = {
      url = "https://go.dev/dl/go${version}.linux-arm64.tar.gz";
      hash = "";
    };
    x86_64-darwin = {
      url = "https://go.dev/dl/go${version}.darwin-amd64.tar.gz";
      hash = "";
    };
    aarch64-darwin = {
      url = "https://go.dev/dl/go${version}.darwin-arm64.tar.gz";
      hash = "";
    };
  };

  platform = stdenv.hostPlatform.system;
  source = sources.${platform}
    or (throw "Unsupported platform: ${platform}");
in
stdenv.mkDerivation {
  pname = "go";
  inherit version;

  src = fetchurl {
    inherit (source) url hash;
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    tar -xzf $src -C $out --strip-components=1
  '';
}
```

Use the [empty hash technique][nix-expression-hashes]
to determine the correct hash for each platform.

### Override a builder function with a custom toolchain

Once you have a vendored toolchain,
you can override nixpkgs builder functions to use it
instead of the default.
For example,
to build a Go project that requires a newer Go than nixpkgs provides:

```{ .nix .copy title=".flox/pkgs/my-go-project.nix" }
{ callPackage, buildGoModule, fetchFromGitHub }:

let
  customGo = callPackage ./go_custom.nix {};

  buildGoModuleCustom = buildGoModule.override {
    go = customGo;
  };
in
buildGoModuleCustom rec {
  pname = "my-go-project";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-go-project";
    rev = "v${version}";
    hash = "";
  };

  vendorHash = "";
}
```

This pattern works for any language ecosystem where nixpkgs provides
an overridable builder function:

| Builder | Override pattern |
| ------- | --------------- |
| `buildGoModule` | `buildGoModule.override { go = customGo; }` |
| `buildNpmPackage` | `buildNpmPackage.override { nodejs = customNodejs; }` |
| `rustPlatform.buildRustPackage` | Build a custom `makeRustPlatform { rustc = ...; cargo = ...; }` |

### Package a pre-built binary

When building from source isn't practical
— for example,
when cargo vendoring fails due to complex git dependencies —
you can package a pre-built binary directly.

For Linux binaries,
use `autoPatchelfHook` to automatically fix dynamic library references
so they resolve from the Nix store instead of system paths:

```{ .nix .copy title=".flox/pkgs/my-tool.nix" }
{ lib, stdenv, fetchurl, autoPatchelfHook, gcc-unwrapped }:

let
  sources = {
    x86_64-linux = {
      url = "https://github.com/example/tool/releases/download/v1.0.0/tool-linux-x64.tar.gz";
      hash = "";
    };
    aarch64-linux = {
      url = "https://github.com/example/tool/releases/download/v1.0.0/tool-linux-arm64.tar.gz";
      hash = "";
    };
    aarch64-darwin = {
      url = "https://github.com/example/tool/releases/download/v1.0.0/tool-darwin-arm64.tar.gz";
      hash = "";
    };
  };

  platform = stdenv.hostPlatform.system;
  source = sources.${platform}
    or (throw "Unsupported platform: ${platform}");
in
stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchurl {
    inherit (source) url hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gcc-unwrapped.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src
    install -m755 my-tool $out/bin/
  '';
}
```

!!! note "Note"
    `autoPatchelfHook` is Linux-only.
    macOS binaries generally don't need patching,
    but may require `__noChroot = true` if they depend on system frameworks
    that the Nix sandbox blocks access to.

!!! note "Note"
    `gcc-unwrapped.lib` provides `libstdc++.so`,
    which is needed by most C++ compiled binaries.
    If the binary links against other shared libraries,
    add those packages to `buildInputs` as well.

## Choosing a strategy

| Scenario | Build type | Recommended approach |
| -------- | ---------- | -------------------- |
| Language deps need pre-fetching for pure builds | Manifest | [Multi-stage vendoring][pure-builds-section] |
| Tool not in Flox Catalog | Manifest | [Nix expression build](#provide-the-dependency-as-a-nix-expression-build) or [flake input](#use-a-flake-input) |
| Newer version of existing nixpkgs package | Nix expression | [Override version and src](#override-an-existing-packages-version) |
| Toolchain version not in nixpkgs | Nix expression | [Vendor pre-built toolchain](#vendor-a-pre-built-toolchain) and [override builder](#override-a-builder-function-with-a-custom-toolchain) |
| Source build impractical | Nix expression | [Package pre-built binary](#package-a-pre-built-binary) |
| Dependency available as a Nix flake | Either | [Flake input](#use-a-flake-input) |

[manifest-builds-concept]: ../concepts/manifest-builds.md
[nix-expression-builds-concept]: ../concepts/nix-expression-builds.md
[catalog-concept]: ../concepts/packages-and-catalog.md
[base-catalog-concept]: ../concepts/base-catalog.md
[pure-builds-section]: ../concepts/manifest-builds.md#pure-builds
[nix-expression-hashes]: ../concepts/nix-expression-builds.md#generating-hashes
[nix-override-example]: ../concepts/nix-expression-builds.md#example-newer-version-of-an-existing-package
[build-concept]: ../concepts/builds.md
[go-vendoring]: ../languages/go.md#vendoring-dependencies-in-pure-builds
[rust-vendoring]: ../languages/rust.md#vendoring-dependencies-in-pure-builds
[nodejs-vendoring]: ../languages/nodejs.md#vendoring-dependencies-in-pure-builds
