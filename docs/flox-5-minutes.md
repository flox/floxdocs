---
title: Flox in 5 minutes
description: Get started with creating Flox environments.
---

# Flox in 5 minutes

Flox is a language agnostic package and environment manager that lets you create reproducible environments that work across machines, architectures, and operating systems. To learn more about what Flox is and what it can do, see the [Introduction][intro].

In this guide you'll use a sample project to create a Flox environment, install packages, set environment variables, run services, and customize your shell.

Buckle up, it's time for a whirlwind tour of Flox.

## Clone the sample project

We've prepared a sample project for you, but you'll need to [install Flox][install_flox] to follow along.
Once you have Flox, you can clone the project:

```{ .bash .copy }
git clone https://github.com/flox/flox-in-5min.git
```

```{ .bash .copy }
cd flox-in-5min
```

## Activate and explore

Run [`flox activate`][activate] to enter the environment. This will make all of the packages defined in the environment available in your shell:

```{ .console }
$ flox activate
✅ You are now using the environment 'flox-in-5min'.
To stop using this environment, type 'exit'
```

With all the dependencies installed, you can confirm everything is working by running the sample Go project:

```{ .console }
$ go run main.go
Hello from Flox!
```

You didn't have to install Go yourself. The environment already had it defined, so `flox activate` made it available automatically. To get started on any project with Flox, all you need is `git clone` and `flox activate`.

Now let's see what else is installed to the environment with the [`flox list`][list] command:

```{ .console }
$ flox list
bun: bun (1.2.20)
coreutils: coreutils (9.7)
go: go (1.24.5)
nasm: nasm (2.16.03)
nodejs_24: nodejs_24 (24.5.0)
```

This environment includes tools across multiple languages, from Go to Node.js to [Bun][bun], all the way down to an assembler like `nasm`. Flox is language agnostic, so you can manage your entire stack of developer tools in one place. Anyone who runs `flox activate` on this project will get the exact same set of packages.

## Managing packages

Flox makes it easy to search for, inspect, and install packages from the Flox Catalog.

Use `flox search` to find packages. For example, to search for `ripgrep`:

```{ .console }
$ flox search ripgrep
ripgrep                           Utility that combines the usability of The Silver Searcher with the raw speed of grep
ripgrep-all                       Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more
emacsPackages.ripgrep             <no description provided>
vimPlugins.blink-ripgrep-nvim     <no description provided>
emacsPackages.projectile-ripgrep  <no description provided>
vgrep                             User-friendly pager for grep/git-grep/ripgrep
repgrep                           Interactive replacer for ripgrep that makes it easy to find and replace across files on the command line
grip-grab                         Fast, more lightweight ripgrep alternative for daily use cases
bat-extras.batgrep                Quickly search through and highlight files using ripgrep

Use 'flox show <package>' to see available versions
```

To check available versions of a package, use `flox show`:

```{ .console }
$ flox show ripgrep
ripgrep - Utility that combines the usability of The Silver Searcher with the raw speed of grep
    ripgrep@14.1.1
    ripgrep@14.1.0
    ripgrep@14.0.3
    ripgrep@14.0.1
    ripgrep@13.0.0
    ripgrep@12.1.1 (aarch64-linux, x86_64-darwin, x86_64-linux only)
```

To install a package, run:

```{ .bash .copy }
flox install ripgrep
```

## Push to FloxHub

Now that you've made changes to the environment, share it with your team by pushing it to [FloxHub][floxhub]. FloxHub is a platform for sharing and discovering Flox environments, making it easy for your team to stay in sync.

If you haven't already, [sign up for a FloxHub account][floxhub_signup]. Then authenticate with the CLI:

```{ .bash .copy }
flox auth login
```

This will open your browser and ask you to confirm the device code displayed in your terminal:

![FloxHub device confirmation](./img/device-confirmation.png)

Push your environment to FloxHub:

```{ .bash .copy }
flox push
```

Once the push is complete, you'll see a confirmation along with commands others can use to access your environment:

![Successful push to FloxHub](./img/auth-successfull.png)

You can view your environment's manifest, packages, environment variables, and services in the FloxHub web interface. This gives your team a quick way to see what's in an environment before pulling it, track changes across generations, and check supported platforms:

![FloxHub environment view](./img/floxhub-environment.png)

## Services

Most projects need more than just packages. You might need a web server, a database, or a background worker running alongside your code. Flox handles this through the `[services]` section of the manifest.

The sample environment includes a simple `stopwatch` service. Start it up:

```{ .console }
$ flox services start
✅ Service 'stopwatch' started.
```

You can check on running services and tail their logs just like you would with any process manager:

```{ .console }
$ flox services status
NAME       STATUS       PID
stopwatch  Running    51774
```

```{ .console }
$ flox services logs --follow
stopwatch: Fri Aug 22 19:17:30 MDT 2025
stopwatch: Fri Aug 22 19:17:35 MDT 2025
stopwatch: Fri Aug 22 19:17:40 MDT 2025
stopwatch: Fri Aug 22 19:17:45 MDT 2025
stopwatch: Fri Aug 22 19:17:50 MDT 2025
stopwatch: Fri Aug 22 19:17:55 MDT 2025
stopwatch: Fri Aug 22 19:18:00 MDT 2025
stopwatch: Fri Aug 22 19:18:05 MDT 2025
```

Press `Ctrl-C` to stop watching the logs. When you're done, stop the service:

```{ .console }
$ flox services stop
✅ Service 'stopwatch' stopped
```

Services are automatically stopped when you exit the environment, so you don't have to worry about orphaned processes. If you want services to start automatically when you enter the environment, use `flox activate -s`.

## What's next?

You've created an environment, installed packages, pushed to FloxHub, and ran services. Here are some next steps to keep going:

- [Customize your shell environment][activation-tutorial] with aliases, scripts, and hooks
- [Design cross platform environments][multi-arch] that work on both macOS and Linux
- [Reuse and combine environments][composition] to build modular developer toolchains
- [Run Flox in CI][ci] for consistent builds across your pipeline
- [Build and publish packages with Flox][build-publish]

Have questions? Reach out on [Slack](https://go.flox.dev/slack){:target="_blank"} or [Discourse](https://discourse.flox.dev){:target="_blank"}.

<!-- ## Customizing your shell

To wrap things up, let's say you want to set some project-specific aliases.
Run `flox edit` and add this to the bottom of your manifest:

```{ .toml .copy }
[profile]
bash = '''
  alias sayhi="echo 'Hello there, bash user'"
'''
zsh = '''
  alias sayhi="echo 'Hello there, zsh user'"
'''
# The superior shell
fish = '''
  alias sayhi "echo 'Hello there, fish user'"
'''
# Hello from 1989
tcsh = '''
  alias sayhi "echo 'Hello there, tcsh user'"
'''
```

Now if you exit the Flox environment via `Ctrl-D` or `exit` and reactivate via `flox activate`, you'll have a wonderful new shell alias called `sayhi`:

```{ .console }
$ sayhi
Hello there, fish user
```

There is a wealth of ways that you can customize the shell environment inside of your Flox environment.
See the [customizing the shell enviroment tutorial][activation-tutorial] for more information. -->

<!-- ## But wait, there's more!

This probably took longer than 5 minutes, but hopefully changing the way you develop software was worth it.
There are _so_ many things we didn't have time to cover, so here's some additional reading material to keep you busy:

- [Designing cross-platform environments][multi-arch]
- [Running Flox in CI][ci]
- [Reusing and combining environments][composition] (modular developer environments!)
- [Replacing Homebrew with Flox][homebrew]
- [Build and publish packages with Flox][build-publish] -->

[intro]: ./index.md
[install_flox]: ./install-flox/install.md
[create_guide]: ./tutorials/creating-environments.md
[sharing]: ./tutorials/sharing-environments.md
[init]: ./man/flox-init.md
[search]: ./man/flox-search.md
[show]: ./man/flox-show.md
[catalog]: ./concepts/packages-and-catalog.md
[install]: ./man/flox-install.md
[activate]: ./man/flox-activate.md
[edit]: ./man/flox-edit.md
[push]: ./man/flox-push.md
[list]: ./man/flox-list.md
[manifest]: ./man/manifest.toml.md
[multi-arch]: ./tutorials/multi-arch-environments.md
[services]: ./concepts/services.md
[bun]: https://bun.sh/
[zig]: https://ziglang.org/
[floxhub]: https://hub.flox.dev
[floxhub_signup]: https://hub.flox.dev/signup
[sleep-issue]: https://github.com/flox/flox/pull/1931
[install-section]: ./man/manifest.toml.md#install
[activation-tutorial]: ./tutorials/customizing-environments.md
[ci]: ./tutorials/ci-cd.md
[composition]: ./tutorials/composition.md
[homebrew]: ./tutorials/migrations/homebrew.md
[build-publish]: ./tutorials/build-and-publish.md
