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
This environment is self contained in the `.flox` directory and can be
reproduced by sharing the directory in version control or some other file
sharing mechanism.
Path environments are created with [`flox init`][flox_init],
referred to with the `--dir/-d` option on most CLI commands,
and are commonly used for self-contained projects or different subprojects
within a monorepo.
1. **Centrally managed environment**: An environment stored remotely on
[FloxHub][floxhub_concept].
Centrally managed environments are created by running [`flox push`][flox_push]
on a path environment.
You can connect a new project directory with an existing centrally managed environment with [`flox pull ...`][flox_pull] or
you can activate the environment directly with [`flox activate --remote ...`][flox_activate] for
instant use.
Centrally managed environments enable multiple projects or systems to consume a
shared environment that is versioned with [generations][generation_concept].
They are commonly used as base environments for projects of similar tech stacks,
for reproducing issues on specific systems, or to quickly share tools.
To disconnect a centrally managed environment from FloxHub, run [`flox pull --copy`][flox_pull] instead of `flox pull`.
This will turn the environment back into a path environment.

See the [sharing guide][sharing_guide] for a more thorough walk through about
sharing and working with different types of environments.

## Environment files

A Flox environment stores its metadata, declarative manifest, and manifest lock
file in a `.flox` directory wherever the [`flox init`][flox_init] command was
run.
Let's look closer at the files that were generated.

### Environment manifest: `.flox/env/manifest.toml`

The manifest is a declarative specification for the environment and contains 5
parts: 

  - **Install:** the packages installed to the environment. 
  - **Vars:** environment variables for use in the activated environment.
  - **Hook:** Bash script executed before passing control to the user's shell.
  - **Profile:** Shell-specific scripts sourced by the user's shell.
  - **Options:** Environment-scoped options such as supported systems.

**[Read more about the manifest][manifest_concept]** and consult the
[customizing environments guide][customizing_environments_guide] to walk through
examples.

### Manifest lock: `.flox/env/manifest.lock`

The lock file serves as a snapshot of the specific versions of dependencies that
were built and activated at a particular point in time.

``` json title="manifest.lock"
{
  "lockfile-version": 0,
 ...
        "input": {
          "attrs": {
            "lastModified": 1703581207,
            "narHash": "3ef...",
            "owner": "NixOS",
            "repo": "nixpkgs",
            "rev": "3ef...",
            "type": "github"
          },
          "fingerprint": "3ef...",
          "url": "github:NixOS/nixpkgs/3ef..."
        },
        "priority": 5
      },
      "nodejs": {    
}
```

### Environment metadata: `.flox/env.json`

A metadata file that contains the name of the environment and the environment's
version. Flox manages this file for you.

``` json title="env.json"
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
[flox_pull]: ../reference/command-reference/flox-push.md
[flox_activate]: ../reference/command-reference/flox-activate.md
[sharing_guide]: ../tutorials/sharing-environments.md
[create_guide]: ../tutorials/creating-environments.md
[customizing_environments_guide]: ../tutorials/customizing-environments.md
[generation_concept]: ./generations.md
[manifest_concept]: ./manifest.md
[floxhub_concept]: ./floxhub.md
[discourse]: https://discourse.flox.dev/
