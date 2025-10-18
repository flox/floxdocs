---
title: Designing cross-platform environments
description: Creating environments that run on different systems.
---

# Designing cross-platform environments

Flox makes it simple to have the **same [environment][environment_concept] on
multiple systems and CPU architectures**.
This guide walks through an example between two coworkers who have different
system types,
and shows how to customize your environment with system-specific dependencies.

## Creating an environment

To get started,
let's create an [environment][environment_concept] from a Linux laptop.
This laptop is using an ARM CPU (aarch64) which makes its full system
type `aarch64-linux`.

When using [`flox search`][flox_search] you may see packages that won't immediately work with your manifest, but finding and allowing system specific packages is very easy.
Flox shows software from the following systems: `aarch64-darwin`, `x86_64-darwin`, `aarch64-linux`, and `x86_64-linux`.

Some packages may support only a subset of system types. You can inspect a
package with [`flox show`][flox_show] to see what system types are supported:

```console
$ flox show gdb
gdb - The GNU Project debugger
    gdb@14.2 (aarch64-linux, x86_64-darwin, x86_64-linux only)
    gdb@14.1 (aarch64-linux, x86_64-darwin, x86_64-linux only)
    gdb@13.2 (aarch64-linux, x86_64-darwin, x86_64-linux only)
    gdb@13.1 (aarch64-linux, x86_64-darwin, x86_64-linux only)
...
```

First let's install some packages to our environment running on Linux:

```console
$ flox init --name eng-team-tools
✨ Created environment eng-team-tools (aarch64-linux)
...
$ flox install gnupg vim
✅ 'gnupg' installed to environment eng-team-tools at /home/youruser
✅ 'vim' installed to environment eng-team-tools at /home/youruser
```

To make it easy to share this system across platforms we are going to share it
on FloxHub with [`flox push`][flox_push].

```console
$ flox push
✅  eng-team-tools successfully pushed to FloxHub

    Use 'flox pull youruser/eng-team-tools' to get this environment in any other location.
```

Learn more about this and other sharing options in the
[sharing environments guide][sharing_guide].

## Using the environment from a different system type

Many packages in Flox will work without any issue across system types.

To test this out, run [`flox pull`][flox_pull] from another system such as an
Apple machine with an M-series processor.
This system type is `aarch64-darwin`.
Then lets run the a simple `gpg --version` command to test everything is working.

```console
$ flox pull youruser/eng-team-tools
✨  Pulled youruser/eng-team-tools from https://hub.flox.dev

    You can activate this environment with 'flox activate'
$ flox activate -- gpg --version
gpg (GnuPG) 2.4.5
libgcrypt 1.10.3
Copyright (C) 2024 g10 Code GmbH
...
```

Looks like the environment works cross-platform, nice!

## Handling unsupported packages

However, some packages only work with a subset of systems.
To demonstrate this let's install a package that **isn't compatible with an Apple machine**.

From the Linux machine...

```console
$ flox install systemd
⚠️  'systemd' installed only for the following systems: aarch64-linux, x86_64-linux
```

Flox installs the package for all systems that it's compatible with,
but it skips Apple systems since they don't support the package.
We can push this update so we can list packages from the Apple machine to verify
everything works.

```console
$ flox push
✅  Updates to eng-team-tools successfully pushed to FloxHub

    Use 'flox pull youruser/eng-team-tools' to get this environment in any other location.
```

Then, from the Apple machine, let's pull the latest and inspect the manifest.

```console
$ flox pull
✅ Pulled youruser/eng-team-tools from https://hub.flox.dev/

You can activate this environment with 'flox activate'

$ flox list
gnupg: gnupg (2.4.5)
vim: vim (9.1.0377)

$ flox list -c
...
[install]
gnupg.pkg-path = "gnupg"
vim.pkg-path = "vim"
systemd.pkg-path = "systemd"
systemd.systems = ["aarch64-linux", "x86_64-linux"]
...
```

The Apple machine does not have `systemd`, because the `systemd.systems` list
specifies that `systemd` should only be installed on Linux.
This environment will activate on both machines and the Apple machine won't
get the `systemd` package.

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Environment concept][environment_concept]

[environment_concept]: ../concepts/environments.md
[sharing_guide]: ./sharing-environments.md
[flox_search]: ../man/flox-search.md
[flox_show]: ../man/flox-show.md
[flox_edit]: ../man/flox-edit.md
[flox_push]: ../man/flox-push.md
[flox_pull]: ../man/flox-pull.md
