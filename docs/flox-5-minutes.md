---
title: Flox in 5 minutes
description: Get started with creating Flox environments.
---

# Flox in 5 minutes

Flox is a next-generation, language-agnostic package and environment manager.
With it you create sets of tools, environment variables, and setup scripts that work reproducibly from machine to machine, x86_64 to Arm, and macOS to Linux.
The best part is that all of this works without causing version conflicts between projects.

We call these stacks **Flox environments**.
Flox environments are based on carefully configured subshells, so there's no container isolation preventing you from using your favorite tools or artisanally handcrafted dotfiles.
Even better, these environments _compose_ and _layer_ so you can prepare different environments
for different needs and combine them to seamlessly work across different contexts.

Finally, you can use Flox environments for local development, CI, and production to ensure that you have a consistent set of software across the entire software development lifecycle.

Buckle up, it's time for a whirlwind tour of Flox.

## Get the project

We've prepared a sample project for you, but you'll need to [install Flox][install_flox] to follow along.
Once you have Flox, you can clone the project:

```{ .bash .copy }
git clone https://github.com/flox/flox-in-5min.git
cd flox-in-5min
```

## Tools prepared for you

Once you have the project, you can run the [`flox activate`][activate] command to enter the environment:

```{ .console }
$ flox activate
✅ You are now using the environment 'flox-in-5min'.
To stop using this environment, type 'exit'
```

You now have all of the dependencies needed to follow along.
To prove it, run the following command:

```{ .console }
$ go run main.go
Hello from Flox!
```

Whoever prepared this environment knew that you needed a Go toolchain in order to work on the project, so they included a Go toolchain in the Flox environment.
_**This is the magic of Flox.**_

To get to work on an existing project you need two commands: `git clone` and `flox activate`.
Onboarding a new engineer now has one step: install Flox.
No more `README.md` with a list of libraries you need install.
No more `setup.sh`.
Time not spent installing tools and solving dependency conflicts is time spent getting to know the team and the project.

Now let's see what else is installed to the environment with the [`flox list`][list] command:

```{ .console }
$ flox list
bun: bun (1.2.20)
coreutils: coreutils (9.7)
go: go (1.24.5)
nasm: nasm (2.16.03)
nodejs_24: nodejs_24 (24.5.0)
```

That's right, not only do you have Go installed, you also have a cutting edge Javascript toolchain with [Bun][bun].
Since Flox is language agnostic, you can use one tool (Flox) to manage your entire stack of developer tools.
This environment covers the full stack, from a [Zig][zig]-powered Javascript bundler and runtime at the top of the stack, to an assembler like `nasm` at the very bottom of the stack.

This environment is also reproducible, meaning that anyone that runs `flox activate` will get exactly the same set of tools, and that's super important!
You'd think that something as simple as the `sleep` command wouldn't cause problems, but `/bin/sleep infinity` will sleep for a surprisingly short time on macOS (ask us how [we know][sleep-issue]).
Ensuring that everyone is using the _exact_ same packages prevents wasted time and subtle bugs.

## Finding packages

Let's say we want a new package: `ripgrep`.

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

Cool, what if I want a specific version?

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

To install it you would run

```{ .bash .copy }
flox install ripgrep
```

## What else can Flox do?

Your environment is stored as a `.flox` directory in your repository, but you can also [`push`][push] it to [FloxHub][floxhub] to make it centrally managed and available from anywhere.
We only have 5 minutes, so we're going to skip over that for now, but see the [sharing environments tutorial][sharing] for more information.

The configuration for your environment is called the ["manifest"][manifest], a TOML file stored at `.flox/env/manifest.toml`.
You can print it with `flox list -c` or edit it with [`flox edit`][edit].

Let's take a look at this manifest:

```{ .bash .copy }
flox list -c
```

```{ .toml .copy }
version = 1

[install]
go.pkg-path = "go"
nodejs_24.pkg-path = "nodejs_24"
ripgrep.pkg-path = "ripgrep"
coreutils.pkg-path = "coreutils"
bun.pkg-path = "bun"
nasm.pkg-path = "nasm"

[vars]
MY_VAR = "pretty neat"

[services.stopwatch]
command = '''
  while true; do date; sleep 5; done
'''
```

Pretty straightforward.
Packages go in `[install]`, and maybe the syntax is a little funky, but that's for a good reason we don't have time to get into.
See [this page][install-section] for more details about the various things you can specify about a package.

What are these `[vars]` and `[services]` sections?

The `[vars]` section defines environment variables you want set in your shell after running `flox activate`.
See for yourself:

```{ .console }
$ echo "$MY_VAR"
pretty neat
```

Imagine using this to set a port number or some other configuration value.

The `[services]` section is how you define background processes for your environment, like a web server or a database.
Start the `stopwatch` service with the `flox services start` command:

```{ .console }
$ flox services start
✅ Service 'stopwatch' started.
```

Let's make sure it's running:

```{ .console }
$ flox services status
NAME       STATUS       PID
stopwatch  Running    51774
```

Now let's see its logs:

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

This service prints the current time every 5 seconds, which you can see defined in the `services.stopwatch.command` field of the manifest.
Press `Ctrl-C` to stop watching the logs, unless you really enjoy that for some reason.
We don't want the service to run forever, so let's stop it with the `flox services stop` command.

```{ .console }
$ flox services stop
✅ Service 'stopwatch' stopped
```

A _really cool_ feature of Flox is that if you were to exit the environment by running `exit` or pressing `Ctrl-D`, the services running in the environment would be automatically stopped.
This feature has given our engineers gray hair, but we think the dopamine hit is worth it.
If you want services to start when you enter the environment, you can use the `-s/--start-services` option when running `flox activate`.

## Customizing your shell

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
See the [customizing the shell enviroment tutorial][activation-tutorial] for more information.

## But wait, there's more!

This probably took longer than 5 minutes, but hopefully changing the way you develop software was worth it.
There are _so_ many things we didn't have time to cover, so here's some additional reading material to keep you busy:

- [Designing cross-platform environments][multi-arch]
- [Running Flox in CI][ci]
- [Reusing and combining environments][composition] (modular developer environments!)
- [Replacing Homebrew with Flox][homebrew]
- [Build and publish packages with Flox][build-publish]

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
[sleep-issue]: https://github.com/flox/flox/pull/1931
[install-section]: ./man/manifest.toml.md#install
[activation-tutorial]: ./tutorials/customizing-environments.md
[ci]: ./tutorials/ci-cd.md
[composition]: ./tutorials/composition.md
[homebrew]: ./tutorials/migrations/homebrew.md
[build-publish]: ./tutorials/build-and-publish.md
