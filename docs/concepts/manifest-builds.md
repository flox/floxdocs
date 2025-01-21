---
title: "Preview: Builds"
description: How to use Flox environments to build artifacts 
---

The typical development lifecycle involves a step where your source code and
potentially some other assets are bundled together into an artifact.
That could be a compiled executable, an archive containing source files, or
something else entirely.
A Flox environment ensures that the same set of tools, dependencies, and
environment variables are available wherever the environment is activated.
You can now integrate builds into your environment to build those artifacts
with the same reproducible set of tools and dependencies that were used to
develop the software.

## Enabling builds

Builds are still in development,
so before you can perform builds you will need to enable a feature flag.

To enable the builds feature temporarily you can set an environment variable:

```bash
$ export FLOX_FEATURES_BUILD=true
```

To make this feature flag persistent you can edit your Flox config:

```bash
$ flox config --set-bool features.build true
```

## Defining builds

Builds are defined in the `[build]` section of the manifest.
Configuring a build mostly entails providing a short Bash script to run to
build the artifact.
This script is run inside the environment so that the tools used to develop
the software are available during the build.

Each build specified in the `[build]` section corresponds to a different
artifact.
This allows you to produce multiple artifacts from a given set of sources,
for example to produce different versions of a compiled binary both with
and without debug symbols.

Finally, `flox` requires that you place your artifacts into a directory called
`$out`,
but we'll provide more details on that aspect later.

An example build definition for a Rust project called `myproject` looks like
this:

```toml
[build.myproject]
command = '''
  cargo build --release
  mkdir -p $out/bin
  cp target/release/myproject $out/bin/myproject
'''
```

As you can see, it's very simple.

### Limiting the package size

Your artifact likely has dependencies,
and those dependencies have their own dependencies,
all the way down to `libc`.
We call this complete set of dependencies the "transitive closure",
or simply "the closure", of your artifact.
A large closure for your artifact has no direct impact on runtime performance,
but it means that your artifact requires more disk space to install and requires
more bandwidth to copy from one place to another.

By default all of the packages in the default [package group][pkg-groups] are
included as dependencies of your artifacts,
but these packages may only be needed by your artifact at _build_ time,
not _run_ time.
As a reminder, the default package group is called `toplevel`,
and all packages installed to an environment without an explicit `pkg-group`
are placed into this package group.

You can restrict the dependencies needed at runtime via the `runtime-packages`
option by listing the `install-id`s
of the dependencies required at runtime:

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

In the example manifest above we install two packages, `hello-go` and `ripgrep`,
and build an artifact that runs the `hello-go` package, called `hello-pkg`.
By setting `runtime-packages = [ "hello" ]`
(the `install-id` of the `hello-go` package is `hello`),
we limit the runtime closure of the `hello-pkg` artifact
to only the `hello-go` package,
eliminating `ripgerp`.

### Where to put artifacts

To keep the output of a build separate from the source files,
every build is supplied with a directory whose path is stored in a variable
named `out`.
Only the files stored in this directory are considered part of the output of
a build and it is empty by default.
This is why you see the following line in the build command for the `myproject`
example above

```sh
mkdir -p $out/bin
cp target/release/myproject $out/bin/myproject
```

The contents of the `$out` directory should adhere to the
[Filesystem Hierarchy Standard (FHS)][fhs-docs],
which is just the official name for the familiar `bin`, `lib`, etc directories
you may be familiar with from using Unix-based systems.

What this means in practice is:

- Executable files should be placed in `$out/bin`, `$out/sbin`,
  or `$out/libexec`. Executable files placed in other directories will likely
  not work properly. Scripts written to these directories still need to be
  marked as executable via `chmod +x`.
- Man pages should be placed in `$out/share/man`.
- Libraries should be placed in `$out/lib`

### Sandboxed builds

The script that you specify in `command` is run on your host machine by default.
This means that it may build against dependencies that are outside of your
environment and the artifact may not function correctly when executed or rebuilt
from another machine.

In order to improve the reproducibility of your build you can specify that it is
run within a sandbox that doesn't have access to the host machine:

```toml
[build.myproject]
sandbox = "pure"
command = '''
  cargo build --release
  mkdir -p $out/bin
  cp target/release/myproject $out/bin/myproject
'''
```

The project has to be within a Git repository and only committed files are
available within the sandbox.

On Linux machines the sandbox also prevents the build from accessing the
network.

## Performing builds

Builds are performed with the `flox build` command.
When invoked with no other arguments, `flox build` will execute each build
listed in the manifest.
You can optionally specify which builds to perform:

```bash
$ flox build myproject
```

For each build that `flox` successfully executes,
a symlink named `result-<name>` will be placed in the root directory of the
project.
These symlinks link to the read-only locations where the contents of each
`$out` directory are stored.
Continuing with the `myproject` example,
after the build you could run the compiled binary via

```bash
$ ./result-myproject/bin/myproject
```

## Examples

We've compiled a list of example commands to demonstrate how to use Flox to
build artifacts in various ecosystems.
You can see that page here: [Builds examples][build-examples].

[services-concept]: ./services.md
[fhs-docs]: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
[pkg-groups]: ./manifest.md#installing-packages-to-package-groups
[build-examples]: ../cookbook/builds/examples.md
