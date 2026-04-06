---
title: "FloxHub environments"
description: "Reusable environments that are centrally managed on FloxHub"
---

A FloxHub environment allows you to centrally manage a Flox environment, tracking changes made to it and allowing the environment to be reused in multiple contexts.

## Background

When you create an environment for your project, you often do so via the [`flox init`][flox-init] command, which creates a `.flox` directory that you can check into source control.

```{ .sh .copy}
flox init
git add .flox
```

This allows you to track changes to the environment the same way that you track changes to your source code, but it also ties this environment to this specific project and Git repository.

Another way of working is to [push][flox-push] an environment to [FloxHub][floxhub] to turn it into a reusable, centrally managed environment.

```{ .sh }
$ flox push
✅ Updates to myenv successfully pushed to FloxHub

View the environment at: https://hub.flox.dev/myuser/myenv
Use this environment from another machine: 'flox activate -r myuser/myenv'
Make a copy of this environment: 'flox pull myuser/myenv'
```

Once pushed, the state and history of this environment are tracked on FloxHub in the form of [generations][generations].
Let's explore how FloxHub environments work and the kinds of workflows they enable.

[flox-init]: ../man/flox-init.md
[flox-push]: ../man/flox-push.md
[floxhub]: ./floxhub.md
[generations]: ./generations.md

## Terminology

We call an environment that has been pushed to FloxHub a **"FloxHub environment"**.
One of the primary benefits of FloxHub environments is that they can be reused in different contexts, by different people, on different machines.

This means you frequently have multiple copies of the environment:

- The copy that lives on FloxHub, which is the source of truth
- The copy that exists locally for a given user on a given machine

We call the copy of the environment on FloxHub the **"upstream"** copy, and the copy on a user's machine the **"local"** copy.

## Getting a FloxHub environment

Once you've pushed an environment to FloxHub, you can then use the [`flox pull`][flox-pull] command to fetch a copy of the environment to your machine.

A FloxHub environment can exist on your machine in two different forms:

<!-- markdownlint-disable MD007 -->
- A cached copy transparently managed by Flox
    - Fetch this manually via `flox pull --reference <owner>/<name>`
- Materialized into a user-specified directory
    - Created via `flox pull <owner>/<name>`
    - Placed into the current directory by default
    - Specify a different directory with the `-d/--directory` flag
<!-- markdownlint-enable MD007 -->

This cached copy is created and managed by the Flox CLI.
Additionally, the Flox CLI will automatically fetch updates from FloxHub (without automatically applying them) so that the locally cached copy of the environment has up to date knowledge of the upstream state.

The upstream state of the environment can be fetched manually via the `flox pull (-r | --reference) <owner>/<name>` command.

## Operations on FloxHub environments

CLI commands that interact with FloxHub environments will primarily operate on the cached copy of the environment.
This allows you to use FloxHub environments offline if a cached copy exists.

As an example, installing a package via [`flox install -r`][flox-install] will operate on the local copy, creating a new [generation][generations] of the local copy.
The Flox CLI indicates when an operation has been performed on the local copy (note the `(local)` text in the example below).

```text
$ flox install -r myuser/myenv ripgrep
✅ 'ripgrep' installed to environment 'myuser/myenv' (local)
```

When the Flox CLI detects that the local and upstream copies are out of sync (for example, you have a new local generation corresponding to the new package you installed), it will notify you with instructions on how to proceed.
For the example above, you would see the following output when activating the environment:

```text
$ flox activate -r myuser/myenv
ℹ️  Environment out of sync with FloxHub.

Local:

 * myuser installed package 'ripgrep (ripgrep)' on mymachine
   Generation:  2
   Timestamp: 2025-12-15 21:04:27 UTC

Remote:

 * myuser imported environment on mymachine
   Generation:  1
   Timestamp: 2025-12-15 18:57:23 UTC

Use 'flox push|pull -r myuser/myenv' to fetch updates or update the environment on FloxHub.

✅ You are now using the environment 'myuser/myenv (local)'.
To stop using this environment, type 'exit'
```

The `flox activate` command succeeds, but the message indicates that you need to run either a `flox pull` or `flox push` command (`flox push` in this case since you have local changes) to synchronize the two copies:

```text
Use 'flox push|pull -r myuser/myenv' to fetch updates or update the environment on FloxHub.
```

Running the `flox push` command syncs local changes to the upstream copy on FloxHub:

```text
$ flox push -r myuser/myenv
✅ Updates to myenv successfully pushed to FloxHub

View the environment at: https://hub.flox.dev/myuser/myenv
Use this environment from another machine: 'flox activate -r myuser/myenv'
Make a copy of this environment: 'flox pull myuser/myenv'
```

[flox-pull]: ../man/flox-pull.md
[flox-install]: ../man/flox-install.md

## Getting information from upstream

### Generations

Both the local and upstream FloxHub environments track their state over time via generations.
For an in-depth explanation of generations, see the [Generations][generations] concept page.

In order to view the list of generations as understood by the local copy, you use the [`flox generations list`][gen-list] command.
To see the list of generations as understood by the upstream copy, you add the `--upstream` flag.

In order to view the _history_ of generations (which displays how the "live" generation has evolved over time, any rollbacks that occurred, etc), you use [`flox generations history`][gen-hist].
Again, the `--upstream` flag will show you the history as understood by the upstream copy.

### Packages

In order to see the list of packages in the local copy of a FloxHub environment you use the [`flox list -r`][flox-list] command.
Add the `--upstream` flag to see the packages in the upstream copy of the FloxHub environment.

[gen-list]: ../man/flox-generations-list.md
[gen-hist]: ../man/flox-generations-history.md
[flox-list]: ../man/flox-list.md

## Activating a FloxHub environment

Activating a FloxHub environment is done via the [`flox activate -r`][flox-activate] command.
This will activate the current state of the local copy of the FloxHub environment, which may not be up to date with the upstream copy.
To activate the environment as it exists upstream, run `flox pull -r <owner>/<name>` before running `flox activate -r`.

[flox-activate]: ../man/flox-activate.md
