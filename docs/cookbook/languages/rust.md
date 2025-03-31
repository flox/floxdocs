---
title: Rust
description: Common questions and solutions for using Rust with Flox
---

# Rust

## What do I need for a basic environment?

First we'll show you the answer, and then we'll explain.
The full example environment can be found in the [floxenvs repository][example_env].

A manifest that provides you a Rust development environment would look like
this:

```toml title="Rust development environment"
version = 1

[install]
# Rust toolchain
cargo.pkg-path = "cargo"
cargo.pkg-group = "rust-toolchain"
rustc.pkg-path = "rustc"
rustc.pkg-group = "rust-toolchain"
clippy.pkg-path = "clippy"
clippy.pkg-group = "rust-toolchain"
rustfmt.pkg-path = "rustfmt"
rustfmt.pkg-group = "rust-toolchain"
rust-lib-src.pkg-path = "rustPlatform.rustLibSrc"
rust-lib-src.pkg-group = "rust-toolchain"
libiconv.pkg-path = "libiconv"
libiconv.systems = ["aarch64-darwin", "x86_64-darwin"]

# rust-analyzer goes in its own group because it's updated
# on a different cadence from the compiler and doesn't need
# to match versions
rust-analyzer.pkg-path = "rust-analyzer"
rust-analyzer.pkg-group = "rust-analyzer"

# Linker
gcc.pkg-path = "gcc"
gcc.systems = ["aarch64-linux", "x86_64-linux"]
clang.pkg-path = "clang"
clang.systems = ["aarch64-darwin", "x86_64-darwin"]

[vars]

[hook]

[profile]

[options]
systems = ["aarch64-darwin", "x86_64-darwin", "aarch64-linux", "x86_64-linux"]
```

The typical Rust developer probably uses [rustup][rustup] to manage their
toolchains.
Flox aims to be an all-in-one solution, so you'll use Flox instead of `rustup`.
The main difference here is that the toolchain components are unbundled in
Flox,
so you'll need to install `cargo` and `rustc` as independent packages.
Some common packages you'll want to install are:

- `cargo`
- `rustc`
- `rustfmt`
- `clippy`
- `gcc` on Linux, `clang` on macOS
- `libiconv` on macOS
- `rustPlatform.rustLibSrc`
- `rust-analyzer`

Let's explain some of those packages.

`cargo` is self-explanatory, it's the default build tool for Rust.
However, all Flox packages automatically install all of their dependencies,
so `cargo` also installs `rustc` on its own.
If that's the case, why do we need a `rustc` package?
The short answer is build scripts (`build.rs` files).

One of the ways that Flox makes environments deterministic and reproducible
is that packages don't expose their dependencies to `PATH`,
so `cargo` doesn't expose its `rustc` to `PATH`.
This is fine in most cases since you often don't need to call `rustc` yourself,
but this becomes an issue for crates that contain `build.rs` build scripts that
manually invoke `rustc`.
However, even if your crate doesn't have a `build.rs`,
it is very common for a transitive dependency to need to link to system
libraries such as `openssl`.
This is why we install a separate `rustc` package.
You may also find that you need to install a `pkg-config` package if some
system libraries aren't found.

Build scripts are also why we install the `gcc` or `clang` package:
build scripts often call out to linkers in addition to `rustc`.

The `libiconv` package is necessary on macOS because the Rust standard library
links against it on macOS.
The `rustPlatform.rustLibSrc` provides the source code for `std` so that
`rust-analyzer` can provide diagnostics and documentation for standard library
code.

As a final step, you want to make sure that your Rust toolchain componenents
share the same exact versions of their dependencies,
so you'll want to add them to a package group
(`rust-toolchain` in the example above).

## How do I use nightly compilers?

Nightly compilers aren't currently packaged in the Flox Catalog.
If you need to use nightly compilers,
you can use our Nix flake support to prepare a flake that provides a nightly
compiler.
You would need to prepare that flake, call it `github:rust-dev/my-nightly`,
and add it to the manifest as a flake package:

```toml
[install]
rust-nightly.flake = "github:rust-dev/my-nightly"
```

Popular projects used by the Nix community for this purpose are:

- [nix-community/fenix][fenix]
- [oxalica/rust-overlay][rust-overlay]

[rustup]: https://rustup.rs
[fenix]: https://github.com/nix-community/fenix
[rust-overlay]: https://github.com/oxalica/rust-overlay

## Add the `target` directory to `PATH`

If you're developing a binary instead of a library,
you may find it useful to add the `target/debug` or `target/release`
directories to your `PATH` for interactive testing.
That is very simple to do with the `hook.on-activate` section of the manifest:

```toml
[hook]
on-activate = '''
  export PATH="$PWD/target/debug:$PATH"
'''
```

Now if you were developing a binary called `mybin`,
you could call it directly instead of via `target/debug/mybin`,
and it will automatically be kept up to date on every `cargo build`.

## Add `cargo` aliases

The `[profile]` section allows you to add aliases to your development shell
that are available after activating your environment.
If you currently use `make`, `just`, or a `.cargo/config.toml` file to set
provide simple aliaes in your development environment,
you may be able to remove those dependencies and just use the Flox manifest
instead:

```toml
[profile]
bash = '''
  alias build="cargo build"
'''
zsh = '''
  alias build="cargo build"
'''
fish = '''
  alias build "cargo build"
'''
```

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

Since the output of the build must be copied to the `$out` directory, you'll need to copy the compiled executable out of the `target` directory and into `$out`.
There is an unstable environment variable in Cargo that will allow you to set the output directory of the build, but we'll stick to stable features here:

```toml
[build.myproject]
command = '''
  cargo build --release
  mkdir -p $out/bin
  cp target/release/myproject $out/bin/myproject
'''
```

[example_env]: https://github.com/flox/floxenvs/tree/main/rust
[build-concept]: ../../concepts/manifest-builds.md
