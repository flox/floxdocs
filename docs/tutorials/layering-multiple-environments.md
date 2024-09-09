---
title: Layering multiple environments
description: Using more than one environment at a time
---

# Layering multiple environments

This guide walks you through creating a default `$HOME` environment and layering
it with a project's path environment.

## Create your default `$HOME` environment

First, let's set up your default environment.
Use [`flox init`][flox_init] in `$HOME` (or `~`).

``` console
$ cd ~
$ flox init
✨ Created environment default (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
```

Now lets [`flox install`][flox_install] **tools that will be useful on any
system** regardless of the project.
Here we are installing `curl`, `gitFull`, `gnupg`, `inetutils`, `tree`, and
`vim`.

``` console
$ flox install curl gitFull gnupg inetutils tree vim
✅ 'curl' installed to environment default at /Users/youruser
✅ 'gitFull' installed to environment default at /Users/youruser
✅ 'gnupg' installed to environment default at /Users/youruser
✅ 'inetutils' installed to environment default at /Users/youruser
✅ 'tree' installed to environment default at /Users/youruser
✅ 'vim' installed to environment default at /Users/youruser
```

Let's inspect the contents of the environment with [`flox list`][flox_list]:

``` console
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

``` 
$ flox activate
flox [default] $ which git
/Users/youruser/.flox/run/aarch64-darwin.default/bin/git
flox [default] $ git --version
git version 2.42.0
```

Everything is working! 

## Make your terminal always use the default `$HOME` environment

Now let's customize a zsh profile so the `default` environment is activated for
every new shell.

!!! note "Note"
    These steps will vary if you are using a different shell such as `bash`.

Edit your `~/.zshrc` file using `vim` from the `default` environment.

``` 
flox [default] $ vim ~/.zshrc
```

Add the following line to the bottom of the file:

``` bash title="For bash .bashrc or zsh .zshrc"
eval "$(flox activate --dir ~)"
```

``` fish title="For fish config.fish"
eval (flox activate --dir=$HOME) | source
```

Save and exit the file.
Open a new terminal window and you should see the `default` environment is now
active!

```
Last login: Tue Feb 13 10:13:12 on ttys013
flox [default] $ 
```

## Layering a project environment

Now that we have our tools in the `default` environment we can layer on a new
environment that brings in project-specific dependencies.
For this example we will use a publicly accessible Node project called
`material-ui`. 

Let's clone the example project to our home directory and enter the project's
directory:

```
flox [default] $ git clone https://github.com/mui/material-ui.git
Cloning into ...
flox [default] $ cd material-ui
```

Use [`flox init`][flox_init] from the `material-ui` directory that we are in.

```
flox [default] $ flox init
✨ Created environment material-ui (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
```

This project only requires `yarn` so let's install it with
[`flox install`][flox_install].

```
flox [default] $ flox install yarn
✅ 'yarn' installed to environment material-ui at /Users/youruser/material-ui
```

Now we're ready to do development on this project!
Let's activate the `material-ui` Flox environment and start `material-ui`'s
development server.

```
flox [default] $ flox activate
flox [material-ui default] $ yarn start
...
```

We now have access to both the dependency this project needs (`yarn`) and the
tools we need to do development on any project (`vim`, `git`, etc)!
You can layer as many environments as you want.
If two environments contain the same package,
Flox will use the package from the last environment activated.

## Where to next

- :simple-readme:{ .flox-purple .flox-heart } [Sharing environments][sharing_guide]
  
- :simple-readme:{ .flox-purple .flox-heart } [Customizing the shell hook][customizing_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Designing multiple architecture environments][multi_arch_guide]

[flox_init]: ../reference/command-reference/flox-init.md
[flox_install]: ../reference/command-reference/flox-install.md
[flox_activate]: ../reference/command-reference/flox-activate.md
[flox_list]: ../reference/command-reference/flox-list.md
[sharing_guide]: ./sharing-environments.md
[customizing_guide]: ./customizing-environments.md
[multi_arch_guide]: ./multi-arch-environments.md
