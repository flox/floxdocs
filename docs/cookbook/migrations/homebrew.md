---
title: Homebrew
description: Common questions and solutions for using Rust with Flox
---

# Homebrew migration guide
Flox can replace Homebrew entirely, or they can be used together.

This guide explains how to introduce Flox into environments where Homebrew is currently being used, either as a replacement or an addition. It introduces new concepts and proposes a basic procedure for mapping packages.

## Why you might want to migrate
Homebrew does a great job, and has been loved as the “missing package manager” for a generation of macOS users. But there are a few reasons you might consider moving to Flox:

* **You want to install packages into discrete environments.** Flox allows you to create as many environments as you need, each with a different set of packages.
* **You need a reproducible manifest.** Flox environments are defined in a TOML manifest that can be shared and reproduced - often across OS and system architectures.
* **You need a broader set of packages.** Homebrew has a sizeable collection of packages, but the Flox Catalog is based on Nixpkgs, the largest collection of packages in the world.
* **You need older versions of packages.** The Flox Catalog contains historical versions of each of its packages - in many cases, going back decades.

## New concepts
Flox works similarly to Homebrew, but there are a few new concepts to be aware of.

### Virtual environments

As a Homebrew user, you will find several of the Flox subcommands familiar:

* `search` is used to find available packages
* `install` is used to install packages
* `uninstall` is used to remove packages

However, there is a fundamental design difference: **Flox installs packages into virtual environments**. These environments live inside directories, and you can have as many as you want. Packages are placed into a central store and mapped into each of your environments based on their needs.

That means there are a few additional subcommands to learn when using Flox:

* `init` creates a new environment
* `activate` activates an environment

### The default environment
Typically, a Flox user will create a [default environment]() in their home directory that is activated each time a new shell is created. This is useful for packages that should be available to the user across all of the contexts where they work.

When Flox is configured with a default environment, it behaves very similarly to Homebrew. The Flox CLI will assume the default environment when you call `flox install` commands.

Creating a Flox default environment is optional.

## Install Flox
Download and install Flox following the [installation instructions]().

## Find and install your first package
This section walks you through the process for finding your installed Homebrew packages in the Flox Catalog.

### Show top-level formulae in Homebrew
First, identify the list of Homebrew packages you have installed.

We recommend using `brew leaves` for this, so you can easily differentiate between the formulae you installed explicitly versus those that were installed as dependencies. The `leaves` subcommand will show the formulae that were directly installed.

For example:

```
% brew leaves
boost
gh
imagemagick
mysql
openssh
```

Then, search Flox for one of the formulae you have installed with Homebrew. In this case, for example, you could choose `boost`:

```
% flox search boost
boost     Collection of C++ libraries
booster   Fast and secure initramfs generator
xgboost   Scalable, Portable and Distributed Gradient Boosting (GBDT, GBRT or GBM) Library
boost155  Collection of C++ libraries
boost159  Collection of C++ libraries
boost15x  Collection of C++ libraries
boost160  Collection of C++ libraries
boost165  Collection of C++ libraries
boost166  Collection of C++ libraries
boost167  Collection of C++ libraries

Showing 10 of 120 results. Use `flox search boost --all` to see the full list.

Use 'flox show <package>' to see available versions
```

The first one on the list is the correct Flox package to install, and it has the same name as the Homebrew package. This will often be the case, but not always.

### Install your first package
To install your first package, use `flox install`:

```
% flox install boost
```

The first time you install a package, Flox will ask you whether you want to create a default environment. If you choose to do so, Flox will then ask you whether you want to configure your dotfiles to automatically activate the new default environment.

```
[show the flow]
```

If you do not choose for this to be automated at the time of your first package installation, you can [follow these instructions]() to add Flox to your dotfiles manually.

### Verifying configuration
Exit your active shell and create a new one, causing the dotfile changes to take effect. The first time this happens, you may experience a short delay while your default environment is materialized.

Once the shell is available, verify that your default environment is active by running `flox` with no arguments:

```
% flox
flox version 1.3.6

Usage: flox OPTIONS (init|activate|search|install|...) [--help]

Use 'flox --help' for full list of commands and more information

✨ Active environments:
  default           /Users/floxfan
```

If you see `default` listed amongst the active environments, your dotfiles have been correctly modified. The default environment will be active whenever you log in.

Verify that your package has been installed using `flox list`:

```
% flox list
boost: boost (boost@1.81.0)
```

## Create project environments
As you continue to migrate packages from Homebrew to Flox, you may find that you don’t need them all in your default environment.

The default environment is intended for packages that should be available to the user across all of the contexts where they work. It is commonly used for general utilities like `gh`, `gnused`, and `curl` that apply to many situations.

Packages that are required for specific contexts (e.g., different projects in a monorepo, different repos, different customer deployments, etc.) are often installed into project environments which are then activated in addition to the default environment.

A project environment can be created using `flox init`:

```
flox [default] % cd node-project

flox [default] % flox init
✨ Created environment 'node-project' (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
  $ flox edit                <- Add environment variables and shell hooks

flox [default] % flox install nodejs
✅ 'nodejs' installed to environment 'node-project'

flox [default] % flox activate
✅ You are now using the environment 'node-project'.
To stop using this environment, type 'exit'

flox [node-project default] %
```

When installing packages that you are accustomed to getting from Homebrew, consider the following guidelines:

* install the packages you always need into your default environment, and
* install the rest into environments for the projects where they are required.

## Completing the migration
Once you have installed all of the Flox packages you need, you have a few options. You can either uninstall Homebrew and use Flox exclusively, or you can use them together.

### Option 1: Uninstalling Homebrew
If Flox has everything you need and is working satisfactorally, you may no longer need Homebrew. In this case, it’s a good idea to uninstall it so it doesn’t affect your system in potentially confusing ways.

To do this, follow [the instructions in the Homebrew FAQ](https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew).

### Option 2: Using Flox and Homebrew together
Homebrew and Flox can be used together, and there is no need to uninstall Homebrew in order to use Flox.

However, if you have the Flox default environment enabled, you should be aware of the order of Homebrew and Flox entries in your dotfiles. Both Homebrew and Flox modify your `PATH`, and the one that appears later in your dotfiles will take precedence. If the same package is installed using both Homebrew and Flox, this order will become important.

We recommend that the Flox default environment activation lines appear lowest in your dotfiles, ensuring that packages in the default environment appear in your `PATH` sooner than those from Homebrew.
