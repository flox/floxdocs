---
title: Homebrew
description: Using Flox to replace or augment Homebrew
---

# Homebrew migration guide

Flox is an environment and package manager all in one. Using Flox, you can create discrete environments containing packages from the Flox Catalog.

Flox can replace [Homebrew](https://brew.sh) entirely, or they can be used together.

This guide explains how to introduce Flox into environments where Homebrew is currently being used, either as a replacement or an addition. It introduces new concepts and proposes a basic procedure for mapping packages.

## Why you might want to migrate
Homebrew does a great job, and has been loved as the “missing package manager” for a generation of macOS users. But there are a few reasons you might consider moving to Flox:

* **You need a cross-platform package manager.** Flox works on both macOS and Linux - x86 and ARM - allowing you to define a set of packages that works the same everywhere.
* **You need a virtual package manager** Flox allows you to create as many environments as you need, each with a different set of packages.
* **You need reproducible environments.** Flox environments are defined in a TOML [manifest][manifest_concept] that can be easily shared, or managed alongside code.
* **You need a broader set of software.** Homebrew has a sizeable collection of packages, but the Flox Catalog is based on Nixpkgs, the largest collection of packages in the world.
* **You need older versions of software.** The Flox Catalog contains historical versions of each of its packages - in many cases, going back decades.

## Install Flox
Download and install Flox following the [installation instructions][install_flox].

## Migrate your first package
Migrating to Flox is a straightforward process of installing Flox packages for each of your Homebrew formulae. This section walks you through the process for identifying the set of Homebrew formulae you currently have installed, searching for the corresponding packages in the Flox Catalog, and installing them.

As a Homebrew user, you will find several of the Flox subcommands familiar:

* [`search`][search] is used to find available packages
* [`install`][install] is used to install packages
* [`uninstall`][uninstall] is used to remove packages

### Show top-level formulae in Homebrew
First, identify the list of Homebrew packages you have installed.

We recommend using `brew leaves` for this, so you can easily differentiate between the formulae you installed explicitly versus those that were installed as dependencies. The `leaves` subcommand will show the formulae that were directly installed.

For example:

```
% brew leaves
aider
awscli
ffmpeg
flake8
gh
gnupg
go
graphviz
htop
isort
jq
neovim
pkgconf
redo
ripgrep
tmux
tree
watch
wget
```

### Search for a package in Flox
Then, search Flox for one of the formulae you have installed with Homebrew. In this case, for example, you could choose `jq`:

```
% flox search jq
jq                   Lightweight and flexible command-line JSON processor
ijq                  Interactive wrapper for jq
jql                  JSON Query Language CLI tool built with Rust
jqp                  TUI playground to experiment with jq
gojq                 Pure Go implementation of jq
jq-lsp               jq language server
jquake               Real-time earthquake map of Japan
jq-zsh-plugin        Interactively build jq expressions in Zsh
vimPlugins.jq-vim    <no description provided>
python37Packages.jq  Python bindings for jq, the flexible JSON processor

Showing 10 of 80 results. Use `flox search jq --all` to see the full list.

Use 'flox show <package>' to see available versions
```

The first one on the list is the correct Flox package to install, and it has the same name as the Homebrew package. This will often be the case, but not always.

### Install your first package
To install your first package, use `flox install`:

```
% flox install jq
```

The first time you install a package, Flox will ask you whether you want to create a [default environment][default_tutorial]. 

```
% flox install jq
Packages must be installed into a Flox environment, which can be
a user 'default' environment or attached to a directory.

! Would you like to install 'jq' to the 'default' environment?
> Yes
  No
[↑↓ to move, enter to select, type to filter]
```

If you choose to do so, Flox will then ask you whether you want to configure your shell to automatically activate the new default environment.

```
The 'default' environment can be activated automatically for every new shell
by adding one line to your .bashrc file:
eval "$(flox activate -d ~ -m run)"

! Would you like Flox to add this configuration to your .bashrc now?
> Yes
  No
[↑↓ to move, enter to select, type to filter]

✅ Configuration added to your .bashrc file.
The 'default' environment will be activated for every new shell.
-> Restart your shell to continue using the default environment.
-> Read more about the 'default' environment at:
   https://flox.dev/docs/tutorials/layering-multiple-environments/#create-your-default-home-environment

✅ 'jq' installed to environment 'default'
```

When Flox is configured with a default environment, it behaves very similarly to Homebrew. The Flox CLI will assume the default environment when you run `flox install` in a directory that doesn't contain an environment of its own.

Creating a Flox default environment is optional.

If you do not choose for this to be automated at the time of your first package installation, you can [follow these instructions][default_tutorial_setup] to add Flox to your dotfiles manually.

### Verify configuration
Exit your active shell and create a new one, causing the dotfile changes to take effect. The first time this happens, you may experience a delay while your default environment is materialized. The next time you open a shell it should be quick because the environment has been cached.

Once the shell is available, you can verify that your default environment is active by running [`flox envs`][envs]:

```
flox [default] % flox envs
✨ Active environments:
  default           /Users/rturk
```

If you see `default` listed amongst the active environments, your dotfiles have been correctly modified. The default environment will be active whenever you log in.

Verify that your package has been installed using [`flox list`][list]:

```
flox [default] % flox list
jq: jq (1.7.1)
```

## Create environments for projects
As you continue to migrate packages from Homebrew to Flox, you may find that you don’t need them all in your default environment.

The default environment is intended for packages that should be available to the user across all of the contexts where they work. It is commonly used for general utilities like `gh`, `gnused`, and `curl` that apply to many situations.

Packages that are required for specific contexts (e.g., different projects in a monorepo, different repos, different customer deployments, etc.) are often installed into path environments which are then activated in addition to the default environment.

That means there are a few additional subcommands to learn when using Flox:

* `init` creates a new environment
* `activate` activates an environment, to make the packages available

View the [creating environments][creating_tutorial] page for more details.

When installing packages that you are accustomed to getting from Homebrew, consider the following guidelines:

* install the packages you always need into your default environment, and
* install the rest into environments for the projects or contexts where they are required.

## Complete the migration
Once you have installed all of the Flox packages you need, you have a few options. You can either uninstall Homebrew and use Flox exclusively, or you can use them together.

### Option 1: Uninstall Homebrew
If Flox has everything you need and is working satisfactorally, you may no longer need Homebrew. In this case, it’s a good idea to uninstall it so it doesn’t affect your system in potentially confusing ways.

To do this, follow [the instructions in the Homebrew FAQ](https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew).

### Option 2: Use Flox and Homebrew together
Homebrew and Flox can be used together, and there is no need to uninstall Homebrew in order to use Flox.

However, if you have the Flox default environment enabled, you should be aware of the order of Homebrew and Flox entries in your dotfiles. Both Homebrew and Flox modify your `PATH`, and the one that appears later in your dotfiles will take precedence. If the same package is installed using both Homebrew and Flox, this order will become important.

We recommend that the Flox default environment activation lines appear lowest in your dotfiles, ensuring that packages in the default environment appear in your `PATH` sooner than those from Homebrew.


[manifest_concept]: ../../concepts/manifest.md
[default_tutorial]: ../default-environment.md
[default_tutorial_setup]: ../default-environment.md#initial-setup
[creating_tutorial]: ../creating-environments.md
[install_flox]: ../../install-flox.md
[search]: ../../reference/command-reference/flox-search.md
[envs]: ../../reference/command-reference/flox-envs.md
[list]: ../../reference/command-reference/flox-list.md
[catalog]: ../../concepts/packages-and-catalog.md
[install]: ../../reference/command-reference/flox-install.md
[uninstall]: ../../reference/command-reference/flox-uninstall.md
[activate]: ../../reference/command-reference/flox-activate.md
