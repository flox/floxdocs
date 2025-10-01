---
title: "Manifest Builds"
description: Manifest builds with Flox
---

See the [builds concept][builds-concept] page for an overview of the different types of builds and how to perform them.

## Overview

Manifest builds are defined in the `[build]` section of the manifest and take place in the context of an environment.
What that means is that a build run by the Flox CLI behaves similarly to activating the environment yourself and running the build commands manually.
This allows you to achieve a level of reproducibility while still being able to run the build commands you're familiar with (`cargo build`, `go build`, etc).

Builds can be performed with varying levels of rigor, or "purity", allowing you to choose for yourself which tradeoffs you want to make between effort and correctness.

In addition to ensuring that the build environment is the same as your developer environment, the Flox CLI will also perform some checks on the result of your build to determine whether there are missing dependencies.
This prevents a scenario in which your package builds without issue, but fails at runtime because a runtime dependency is missing.

All of this serves to ensure that the process of building your software is reliable, reproducible, and well understood, while at the same time providing a helping hand to ensure that your software behaves as expected at run time.

## Defining builds

Each build specified in the `[build]` section corresponds to a different package.
This allows you to produce multiple packages from a given set of sources, to produce, for example, a production build, a debug build, and an archive of the build sources all at the same time.

Configuring a build entails providing a short Bash script containing the build instructions.
This script often contains the same commands you would normally run to build the package in your shell e.g. `make`, `cargo build`, etc.
Flox runs this script inside an activation of the environment so that the tools used to develop the software are available during the build.
You can optionally define a `version` and `description` for the package to provide metadata used during the [publish][publish-concept] process.
See the [build section of the manifest reference][manifest-reference] for more details on the available options.

An example build definition for a Rust project called `myproject` looks like this:

```toml
[build.myproject]
command = '''
  cargo build --release
  mkdir -p $out/bin
  cp target/release/myproject $out/bin/myproject
'''
version = "0.0.1"
description = "The coolest project ever"
```

Your build script can refer to other builds in the same manifest via the `${name}` syntax, where `name` is the name of another build defined in the `[build]` section of your manifest.
Builds referred to this way will be performed before the build that references them.
This allows you to perform multi-stage builds.
This is important for "pure" builds, which will be discussed shortly.

### Build outputs

To keep the output of a build separate from the source files, every build is supplied with a directory whose path is stored in a variable named `out`.
Only the files stored in this directory are considered part of the output of a build and it is empty by default.
This is why you see the following line in the build command for the `myproject` example above

```sh
mkdir -p $out/bin
cp target/release/myproject $out/bin/myproject
```

The contents of the `$out` directory should adhere to the [Filesystem Hierarchy Standard (FHS)][fhs-docs], which is just the official name for the familiar `bin`, `lib`, etc directories you may be familiar with from using Unix-based systems.

What this means in practice is:

- Executable files should be placed in `$out/bin`, `$out/sbin`, or `$out/libexec`. Executable files placed in other directories will likely not work properly. Scripts written to these directories still need to be marked as executable via `chmod +x`.
- Man pages should be placed in `$out/share/man`.
- Libraries should be placed in `$out/lib`
- Configuration should be placed in `$out/etc`.

## Pure builds

Builds can be performed with different levels of "purity", meaning different levels of access to the outside world.
This is controlled with the `sandbox` option.

By default this option is set to `"off"`, which instructs the Flox CLI to perform the build in the root of the repository with no restrictions on network or filesystem access.
This is convenient because it allows your build scripts to work as they do in your development environment, such as using local caches and intermediate build artifacts that already exist.
However, that also implies that builds can access and embed information about files (e.g. configuration in `$HOME`) or programs (e.g. system wide applications) that are specific to your machine.
This can subsequently hurt the reproducibility of the build script and the ability to run binaries on other machines where those referenced files do not exist.

When set to `sandbox = "pure"` the Flox CLI is instructed to perform the build in a clean environment.
This entails copying all files tracked by `git` into a temporary directory and running the build in a sandboxed environment that limits filesystem access to those files copied to the temporary build directory.
Sandboxed builds on Linux are also restricted from accessing the network, but the sandboxing mechanisms on macOS are somewhat limited and thus pure builds on macOS **_will still have network access_**.
This provides much stronger guarantees that the build is reproducible, but will often require some additional changes to your build scripts.

### Vendoring dependencies

Many language ecosystems rely on network access to fetch dependencies or access to a global cache of previously fetched dependencies.
Pure builds on both macOS and Linux disallow filesystem access to these global filesystem locations.
Similarly, pure builds on Linux disallow network access and thus prevent build tools from fetching dependencies or refreshing package indices.
This means that pure builds must already have all of their dependencies present in the build environment.

One way to accomplish this is with a multi-stage build where an impure build produces an output containing the vendored dependencies, and then a pure build in turn depends on that build using the `${name}` syntax in its build script to place the vendored dependencies in a location that the build tooling can understand.

Here's an abbreviated example demonstrating how to achieve this pattern with Go (see the [Go cookbook page][go-example] for more precise instructions):

```toml
[build.deps]
command = '''
  mkdir -p $out/etc
  go mod vendor -o $out/etc/vendor
'''

[build.myproject]
command = '''
  cp -r ${deps}/etc/vendor ./vendor
  go build
'''
sandbox = "pure"
```

## What can you build?

The obvious answer to this question is, of course, "software", but this omits a variety of interesting use cases that may not be immediately obvious.

At the end of the day, a "build" is just a script that runs in your activated environment and places one or more files into a directory.
Once that build is done, the package can be [published][publish-concept] so that your or anyone else in your [organization][organizations-concept] can install it into their environment.
This can be a very convenient method of distributing all kinds of files, regardless of whether they're executables or configuration files.

Sharing packages with other users is only possible with an organization.
See the [organizations][organizations-concept] page for more details on organizations.

In short, if you have a file that can be copied into the `$out` directory, it can be distributed to others in your organization with Flox.

### Example: configuration files

Say that Nginx is used as a web server throughout your organization, and there is some common configuration that you want every instance to include (e.g. always listen on the same local port, etc).
Flox environments don't allow you to package arbitrary files along with them, but a build that produces this config file can be published and then consumed by anyone with access to your private catalog.

That build would be very simple:

```toml
[build.nginx_config]
command = '''
  mkdir -p $out/etc
  cp nginx.conf $out/etc/nginx.conf
'''
```

Once this packge is published, any environment that installs it would then be able to reference the config file as `$FLOX_ENV/etc/nginx.conf`.

### Example: protocol buffers

Say that your organization uses [grpc][grpc] to communicate between services.
It's common to vendor the `.proto` files in each project's repository or store the `.proto` files in a separate, central repository for each project to refer to.
However, you could also write a build that copies these `.proto` files and publishes them as a package.
This allows you to version and attach metadata to the `.proto` files, and any team that "installs" the package would have access to them.

Furthermore, since these `.proto` files are installed as a package, any environment that installs them would be notified when there are updates available.

## Limiting the package size

Your package likely has dependencies, and those dependencies have their own dependencies, all the way down to `libc`.
We call this complete set of dependencies the "transitive closure", or simply "the closure", of your package.
A large closure for your package has no direct impact on runtime performance, but it means that your package requires more disk space to install and requires more bandwidth to copy from one place to another.

By default all of the packages in the default [package group][pkg-groups] are included as dependencies of your packages, but these packages may only be needed by your package at _build_ time or _development_ time, not _run_ time.
As a reminder, the default package group is called `toplevel`, and all packages installed to an environment without an explicit `pkg-group` are placed into this package group.

The `runtime-packages` option allows you to trim down the packages from the `toplevel` package group that are included as runtime dependencies of your package.
This option is a list of `install-id`s from the `toplevel` package group.
As a reminder, the `install-id` is the part of the package descriptor that comes before `pkg-path` e.g. `myhello` in `myhello.pkg-path = "hello"`.

Below is an example manifest that installs two packages needed for development, `hello-go` and `ripgrep`, and restricts the runtime dependencies of the build to only `hello-go` (omitting `ripgrep`):

```toml
version = 1

[install]
hello.pkg-path = "hello-go"
ripgrep.pkg-path = "ripgrep"

[build.hello-pkg]
command = '''
  mkdir -p $out/bin
  echo "hello-go" > $out/bin/hello-pkg
  chmod +x $out/bin/hello-pkg
'''
runtime-packages = [ "hello" ] # List of `install-id`s

[options]
systems = ["aarch64-darwin", "x86_64-darwin", "aarch64-linux", "x86_64-linux"]
```

Note again that we include the `install-id` `"hello"` in `runtime-packages`, not the name of the package itself (`hello-go`).

## Examples

We've compiled a list of example commands to demonstrate how to use Flox to build packages in various ecosystems.
Each language guide in the Languages section of the Cookbook contains an example of building a package with Flox.
For example, [this section][go-example] contains an example build for the Go language.

[builds-concept]: ./builds.md
[manifest-reference]: ../reference/command-reference/manifest.toml.md#build
[services-concept]: ./services.md
[publish-concept]: ./publishing.md
[fhs-docs]: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
[pkg-groups]: ../reference/command-reference/manifest.toml.md#package-descriptors
[grpc]: https://grpc.io/
[organizations-concept]: ./organizations.md
[go-example]: ../languages/go.md#build-with-flox
