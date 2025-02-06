---
title: Layering multiple environments
description: Using more than one environment at a time
---

# Layering multiple environments

This guide walks you through layering a [`default`][default-env] environment
with a project's environment.

## Create your default `$HOME` environment

First, create your `default` environment by following
[`default` environment tutorial][default-env].

## Install packages

Now lets [`flox install`][flox_install] **tools that will be useful on any
system** regardless of the project.
Here we are installing `curl`, `gitFull`, `gnupg`, `inetutils`, `tree`, and
`vim`.

```console
$ flox install curl gitFull gnupg inetutils tree vim
✅ 'curl' installed to environment default at /Users/youruser
✅ 'gitFull' installed to environment default at /Users/youruser
✅ 'gnupg' installed to environment default at /Users/youruser
✅ 'inetutils' installed to environment default at /Users/youruser
✅ 'tree' installed to environment default at /Users/youruser
✅ 'vim' installed to environment default at /Users/youruser
```

Let's inspect the contents of the environment with [`flox list`][flox_list]:

```console
$ flox list
curl: curl (8.4.0)
gitFull: gitFull (2.42.0)
gnupg: gnupg (2.4.1)
inetutils: inetutils (2.5)
tree: tree (2.1.1)
vim: vim (9.0.2116)
```

We can test the environment is working properly with
[`flox activate`][flox_activate].

```console
$ flox activate
flox [default] $ which git
/Users/youruser/.flox/run/aarch64-darwin.default/bin/git
flox [default] $ git --version
git version 2.42.0
```

Everything is working!

## Layering a project environment

Now that we have our tools in the `default` environment we can layer on a new
environment that brings in project-specific dependencies.
For this example we will use a publicly accessible Node project called
`material-ui`.

Let's clone the example project to our home directory and enter the project's
directory:

```console
flox [default] $ git clone https://github.com/mui/material-ui.git
Cloning into ...
flox [default] $ cd material-ui
```

Use [`flox init`][flox_init] from the `material-ui` directory that we are in.

```console
flox [default] $ flox init
✨ Created environment material-ui (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
```

This project only requires `yarn` so let's install it with
[`flox install`][flox_install].

```console
flox [default] $ flox install yarn
✅ 'yarn' installed to environment material-ui at /Users/youruser/material-ui
```

Now we're ready to do development on this project!
Let's activate the `material-ui` Flox environment and start `material-ui`'s
development server.

```console
flox [default] $ flox activate
flox [material-ui default] $ yarn start
...
```

We now have access to both the dependency this project needs (`yarn`) and the
tools we need to do development on any project (`vim`, `git`, etc)!
You can layer as many environments as you want.
If two environments contain the same package,
Flox will use the package from the last environment activated.

You can use `flox envs` to see the environments you have activated.

```console
$ flox envs
✨ Active environments:
  material-ui  /home/youruser/material-ui
  default      /home/youruser

Inactive environments:
```

## Where to next

- :simple-readme:{ .flox-purple .flox-heart } [Sharing environments][sharing_guide]
  
- :simple-readme:{ .flox-purple .flox-heart } [Customizing the shell hook][customizing_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Designing multiple architecture environments][multi_arch_guide]

[default-env]: ./default-environment.md
[flox_init]: ../reference/command-reference/flox-init.md
[flox_install]: ../reference/command-reference/flox-install.md
[flox_activate]: ../reference/command-reference/flox-activate.md
[flox_list]: ../reference/command-reference/flox-list.md
[sharing_guide]: ./sharing-environments.md
[customizing_guide]: ./customizing-environments.md
[multi_arch_guide]: ./multi-arch-environments.md
