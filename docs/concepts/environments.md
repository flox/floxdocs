---
title: What is a Flox environment?
description: Everything you need to know about Flox environments.
---

# What is a Flox environment?

An environment is a shell that provides a collection of
**environment variables**, **software packages**, and **activation scripts** that
are run when entering the shell.
Environments provide packages that take precedence over your existing packages
without removing access to personalizations not provided by the environment.
Flox environments layer on top of your system so that you can use the
environment's software when it's active,
while still using your personal shell aliases, IDE, tools, and
kitted out text editor.

See the [creating an environment guide][create_guide] to create your first
environment.

## Environment uses

1. **Path environment**: An environment stored in a local directory.
    - This environment is self contained in the `.flox` directory and can be
reproduced by sharing the directory in version control or some other file
sharing mechanism.
    - Path environments are created with [`flox init`][flox_init],
referred to with the `--dir/-d` option on most CLI commands,
and are commonly used for self-contained projects or different subprojects
within a monorepo.

2. **Centrally managed environment**: An environment stored remotely on
[FloxHub][floxhub_concept].

    - Centrally managed environments are created by running [`flox push`][flox_push]
on a path environment.
     You can connect a new project directory with an existing centrally managed environment with [`flox pull ...`][flox_pull] or you can activate the environment directly with [`flox activate --remote ...`][flox_activate] for instant use.
    - Centrally managed environments enable multiple projects or systems to consume a
shared environment that is versioned with [generations][generation_concept].
They are commonly used as base environments for projects of similar tech stacks,
for reproducing issues on specific systems, or to quickly share tools.
    - To disconnect a centrally managed environment from FloxHub, run [`flox pull --copy`][flox_pull] instead of `flox pull`.
    This will turn the environment back into a path environment.

See the [sharing guide][sharing_guide] for a more thorough walk through about
sharing and working with different types of environments.

## Environment files

A Flox environment stores its metadata, declarative manifest, and manifest lock
file in a `.flox` directory wherever the [`flox init`][flox_init] command was
run.
All of these files can be stored in version control when working with path environments.

Let's look closer at the files that were generated.

### `manifest.toml`

The manifest is a declarative specification for the environment which is [TOML][toml_spec] formatted.

The best way to edit the manifest is by running [`flox edit`][flox_edit] which will launch your default editor and run validation when you save changes.

See [`manifest.toml`][manifest] for a complete description of the manifest format and the [customizing environments guide][customizing_environments_guide] to walk through examples.

```toml title=".flox/env/manifest.toml"
version  = 1

[install]
nodejs.pkg-path = "nodejs_24"
```

### `manifest.lock`

The lock file serves as a snapshot of the specific package versions and their dependencies that were built and activated at a particular point in time.
Flox manages this file for you.

``` json title=".flox/env/manifest.lock"
{
  …
  "packages": [
    {
      "install_id": "nodejs",
      "version": "24.0.1",
      "system": "aarch64-darwin",
      "outputs": {
        "dev": "/nix/store/by9av8x8vmk8lpw4cxhhxfbf7s1h4xzx-nodejs-24.0.1-dev",
        "libv8": "/nix/store/li49fpxxlgzaz20sahhfj6n8cbkqi7m1-nodejs-24.0.1-libv8",
        "out": "/nix/store/naafq480zhq05xbi2d3kzpnna2rdqsfb-nodejs-24.0.1"
      },
  …
}
```

### `pkgs`

[Nix expression builds][nix-expression-builds-concept] are stored in the directory `.flox/pkgs`.

### `env.json`

A metadata file that contains the name of the environment and the environment's
version. Flox manages this file for you.

``` json title=".flox/env.json"
{
  "name": "example-project",
  "version": 1
}
```

[flox_init]: ../reference/command-reference/flox-init.md
[flox_show]: ../reference/command-reference/flox-show.md
[flox_edit]: ../reference/command-reference/flox-edit.md
[flox_install]: ../reference/command-reference/flox-install.md
[flox_search]: ../reference/command-reference/flox-search.md
[flox_edit]: ../reference/command-reference/flox-edit.md
[flox_push]: ../reference/command-reference/flox-push.md
[flox_pull]: ../reference/command-reference/flox-pull.md
[flox_activate]: ../reference/command-reference/flox-activate.md
[sharing_guide]: ../tutorials/sharing-environments.md
[create_guide]: ../tutorials/creating-environments.md
[customizing_environments_guide]: ../tutorials/customizing-environments.md
[generation_concept]: ./generations.md
[floxhub_concept]: ./floxhub.md
[discourse]: https://discourse.flox.dev/
[manifest]: ../reference/command-reference/manifest.toml.md
[nix-expression-builds-concept]: ./nix-expression-builds.md
[toml_spec]: https://toml.io/en/v1.0.0
