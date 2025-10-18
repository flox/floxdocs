---
title: "Builds"
description: Understanding how to build packages with Flox
---

The typical development lifecycle involves a step where your source code and potentially some other assets are bundled together into a package.
That package could be a compiled executable, an archive containing source files, or something else entirely.

A Flox environment ensures that the same set of tools, dependencies, and environment variables are available where the environment is activated, whether that's during development, running in CI, or _when building packages_.
Flox environments have native support for defining builds that should be performed in the context of the environment, making it quick and easy to transition from _developing_ your software in a reliable and reproducible way, to _building_ your software in a reliable and reproducible way.

## Defining builds

There are two ways to define builds, depending on your needs:

* [Manifest builds][manifest-builds-concept] allow you to use the tools and commands you're already familiar with to easily build packages with a reasonable amount of reproducibility
* [Nix expression builds][nix-expression-builds-concept] are for truly reproducible builds and modify existing packages, if you're already familiar with or willing to learn some of the Nix language

## Performing builds

Builds are performed with the [`flox build`][flox-build] command.
When invoked with no other arguments, `flox build` will execute each build defined in the environment.
You can optionally specify which builds to perform:

```{ .bash .copy }
flox build myproject
```

For each build that `flox` successfully executes, a symlink named `result-<name>` will be placed in the root directory of the project.
These symlinks link to the read-only locations where the contents of each package are stored.
Continuing with the `myproject` example, after the build you could run the compiled binary via

```{ .bash .copy }
./result-myproject/bin/myproject
```

## Cross-platform builds

When you build a package, it is built on your host machine, and therefore only built for the system (`aarch64-darwin`, `x86_64-linux`, etc) of your host machine.
This means that if you want packages built for multiple platforms, you need to run the build on multiple platforms.
One way to accomplish this is to run your builds in [CI][flox-ci-cd].

[manifest-builds-concept]: ./manifest-builds.md
[nix-expression-builds-concept]: ./nix-expression-builds.md
[flox-build]: ../man/flox-build.md
[flox-ci-cd]: ../tutorials/ci-cd.md
