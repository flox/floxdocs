---
title: "Builds"
description: How to use Flox environments to build artifacts 
---

The typical development lifecycle involves a step where your source code and
potentially some other assets are bundled together into an artifact.
That could be a compiled executable, an archive containing source files, or
something else entirely.
A Flox environment ensures that the same set of tools, dependencies, and
environment variables are available wherever the environment is activated.
You can now perform builds in the context of that environment so that you have
access to the same set of tools, scripts, and environment variables available
during your builds as you do during development.

## Defining builds

Builds are defined in the `[build]` section of the manifest.
Each build specified in the `[build]` section corresponds to a different
artifact.
This allows you to produce multiple artifacts from a given set of sources,
for example to produce different versions of a compiled binary both with
and without debug symbols.

Configuring a build mostly entails providing a short Bash script containing the
instructions to build the artifact.
This script often contains the same commands you would normally run to build
the artifact in your shell e.g. `make`, `cargo build`, etc.
Flox runs this script inside an activation of the environment so that the tools
used to develop the software are available during the build.
The script must also place the artifact into a directory called `$out`,
but we'll provide more details on that aspect in just a moment.

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
- Configuration should be placed in `$out/etc`.

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

## What can you build?

The obvious answer to this question is, of course, "software",
but this omits a variety of interesting use cases that may not be immediately
obvious.

At the end of the day, a "build" is just a script that runs in your activated
environment and places one or more files into a predefined directory.
Once that build is done, the artifact can be [published][publish-concept] so
that your or anyone else in your organization can install it into their environment.
This can be a very convenient method of distributing files.
Sharing artifacts with other users is only possible with an organization.
See the [organizations][organizations-concept] page for more details on organizations.

In short, if you have a file that can be copied into the `$out` directory,
it can be distributed to others in your organization with Flox.

### Example: configuration files

Say that Nginx is used as a web server throughout your organization, and there
is some common configuration that you want every instance to include
(e.g. always list on the same local port, etc).
Flox environments don't allow you to package arbitrary files along with them,
but a build that produces this config file can be published and then consumed
by anyone with access to your private catalog.

That build would be very simple:

```toml
[build.nginx_config]
command = '''
  mkdir -p $out/etc
  cp nginx.conf $out/etc/nginx.conf
'''
```

Any environment that installs this package after it has been published would
then be able to reference the config file as `$FLOX_ENV/etc/nginx.conf`.

### Example: protocol buffers

Say that your organization uses [grpc][grpc] to communicate between services.
You could vendor the `.proto` files in your project's repository, or store
the `.proto` files in a separate repository.
However, you could also write a build that copies these `.proto` files and
publish the artifact.
This allows you to version and attach metadata to the `.proto` files,
and any team that "installs" the artifact would have access to them.

Furthermore, since these `.proto` files are installed as a package,
any environment that installs them would be notified when there are updates
available.

## Limiting the package size

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
but these packages may only be needed by your artifact at _build_ time or _development_ time,
not _run_ time.
As a reminder, the default package group is called `toplevel`,
and all packages installed to an environment without an explicit `pkg-group`
are placed into this package group.

The `runtime-packages` option allows you to trim down the packages from the `toplevel`
package group that are included as runtime dependencies of your artifact.
This option is a list of `install-id`s from the `toplevel` package group.
As a reminder, the `install-id` is the part of the package descriptor that
comes before `pkg-path` e.g. `myhello` in `myhello.pkg-path = "hello"`.

Below is an example manifest that installs two packages needed for development,
`hello-go` and `ripgrep`, and restricts the runtime dependencies of the build to
only `hello-go` (omitting `ripgrep`):

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

Note again that we include the `install-id` `"hello"` in `runtime-packages`,
not the name of the package itself (`hello-go`).

## Sandboxed builds

The script that you specify in `command` is run on your host machine by default.
This means that it may build against dependencies that are outside of your
environment and the artifact may not function correctly when executed or rebuilt
on another machine.

In order to improve the reproducibility of your build you can specify that it is
run within a sandbox that doesn't have access to the host machine:

```toml
[build.myproject]
sandbox = "pure" # enable the sandbox
command = '''
  cargo build --release
  mkdir -p $out/bin
  cp target/release/myproject $out/bin/myproject
'''
```

The project has to be within a Git repository, and only committed files are
available within the sandbox.

On Linux machines the sandbox also prevents the build from accessing the
network.

## Examples

We've compiled a list of example commands to demonstrate how to use Flox to
build artifacts in various ecosystems.
You can see that page here: [Builds examples][build-examples].

[services-concept]: ./services.md
[publish-concept]: ./publishing.md
[fhs-docs]: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
[pkg-groups]: ./manifest.md#installing-packages-to-package-groups
[build-examples]: ../cookbook/builds/examples.md
[grpc]: https://grpc.io/
[organizations-concept]: ./organizations.md
