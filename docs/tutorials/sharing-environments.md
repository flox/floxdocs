---
title: Sharing your environments
description: Multiple ways to share your environment with others.
---

# Sharing your environments

Flox provides **three main ways of sharing environments** with others:

- **Sharing environments with files:**: Flox environments are shared via the `.flox` folder and often checked into version control.
- **Sharing environments on FloxHub**: Flox environments are shared via FloxHub and available to all command line commands (including RC files) with `-r username/environment`. Commands operate on your local copy; use `flox push` to sync changes to FloxHub.
- **Containers**: Flox environments are containerized or used to create container images.

## Sharing environments with files

New [environments][environment_concept] created with [`flox init`][flox_init] will create a `.flox` folder in the directory where [`flox init`][flox_init] was run. This folder contains everything required to run this environment on their system and can be sent to another user any way files are shared. It is most common to commit the `.flox` to a version controlled code repository such as git. If shared this way, the user needs only `git clone` the project and `flox activate` in the directory containing the `.flox`.

!!! note "Note"
    If you are sharing an environment with a user on a different CPU architecture or OS from the person who created the environment, you may run into some issues where system-specific packages are not available on their OS. This can be fixed with a minor edit to the manifest, described in the [manifest concept][manifest_concept]. If you get stumped, reach out to us on our [forum][discourse] for assistance.

Here is an example of sharing a project with files. The first person creates the environment:

```console
$ mkdir example-project # (1)!
$ cd example-project
$ git init
...
$ flox init
...
```

1. `example-project` is a stand-in for a git source code managed project.

Install packages:

```console
$ flox install inetutils neovim curl
✅ 'inetutils' installed to environment example-project at /Users/youruser/example-project
✅ 'neovim' installed to environment example-project at /Users/youruser/example-project
✅ 'curl' installed to environment example-project at /Users/youruser/example-project
```

Add the `.flox` directory and commit the changes.

```{ .sh .copy }
git add .flox;
git commit -m "sharing flox environment"
```

Another developer on the same project can get started immediately with [`flox activate`][flox_activate], which will automatically download the same versions of those packages to their machine:

```{ .sh .copy }
git clone ..example-project;
flox activate
```

[flox_init]: ../man/flox-init.md
[discourse]: https://discourse.flox.dev/
[manifest_concept]: ../concepts/environments.md#manifesttoml

## Sharing environments on FloxHub

### [`flox push`][flox_push] for the first time

The [`flox push`][flox_push] command makes it easy to share your environment using [FloxHub][floxhub_concept]. When you [`flox push`][flox_push] for the first time, you can create an account on FloxHub for free and send your environment's manifest and metadata for easy sharing.

```console
$ flox push
✅  example-project successfully pushed to FloxHub

    Use 'flox pull youruser/example-project' to get this environment in any other location.
```

You can also view your new environment in FloxHub's web application.

### Directly activating a FloxHub environment

As the recipient, you can use the environment in a variety of ways depending on your needs. If you trust the user sending the environment, [`flox activate -r username/environment`][flox_activate] the environment directly. The first time you do this you will be offered a choice about trusting this user in the future.

```console
$ flox activate -r youruser/example-project
Environment youruser/example-project is not trusted.

    flox environments do not run in a sandbox.
    Activation hooks can run arbitrary code on your machine.
    Environments need to be trusted to be activated.
? Do you trust youruser/example-project?
  Do not trust, ask again next time
  Do not trust, save choice
  Trust, ask again next time
  > Trust, save choice
  Show the manifest

Trusted environment youruser/example-project
```

```console
flox [youruser/example-project] $ telnet --version
telnet (GNU inetutils) 2.5
...
```

### Pulling a FloxHub environment (and pushing updates)

If you intend to use the same environments across multiple projects or you want to stage changes before pushing to FloxHub, you may want to [`flox pull`][flox_pull] it instead.

[`flox pull`][flox_pull] adds a `.flox` folder to the directory you are in that is linked to the FloxHub environment. When using a [FloxHub][floxhub_concept] environment in multiple projects it allows centralized management of the dependencies used across these projects. Run `flox pull` to sync the latest changes from FloxHub:

```console
$ cd similar-example-project
$ flox pull youruser/example-project
✨  Pulled youruser/example-project from https://hub.flox.dev

    You can activate this environment with 'flox activate'
```

After pulling an environment you can install changes to it locally and, when you're ready, [`flox push`][flox_push] them to FloxHub if the environment is unlocked:

```console
$ flox install yarn
✅ 'yarn' installed to environment youruser/example-project at /Users/youruser/similar-example-project
$ flox push
✅  Updates to example-project successfully pushed to FloxHub

    Use 'flox pull youruser/example-project' to get this environment in any other location.
```

Changes are made to your local copy first. Use `flox push` to sync them to FloxHub so others can access the updates.

!!! note "Note"
    Right now, only environment owners can push edits to their environments.

[flox_push]: ../man/flox-push.md
[flox_pull]: ../man/flox-pull.md
[flox_activate]: ../man/flox-activate.md
[floxhub_concept]: ../concepts/floxhub.md

### Pulling a FloxHub environment without connecting to FloxHub

Sometimes you may want to use a FloxHub environment as a template starting point for your project but it will grow to have different environment definitions across multiple projects.
In this cases, you may want to [`flox pull --copy`][flox_pull] instead of [`flox pull`][flox_pull].

[`flox pull --copy`][flox_pull], like [`flox pull`][flox_pull], will create a `.flox` folder to the directory you are in. However, this environment will **not be linked to FloxHub**.
This can make it easy to start multiple projects with the same starting point like, for example, a PostgreSQL template:

```console
$ cd new-postgres-project
$ flox pull --copy flox/postgres # (1)!
✨ Created path environment from flox/postgres.

You can activate this environment with 'flox activate'
```

1. An example pulling a PostgreSQL template that Flox maintains.

This new project will not exist on FloxHub until it's pushed with [`flox push`][flox_push].

!!! note "Note"
    It's easy to rename environments created with `flox pull --copy` with `flox edit -n projectname`.

### Always using the same environment across multiple devices

It can be useful to share the same environment across multiple machines where an install to one will install to the others. To do this, you need to [`flox push`][flox_push] your environment and add a [`flox activate -r`][flox_activate] to your terminal's RC file. Let's look at an example using the environment `youruser/example-project` for a zsh user, so we can have everything we installed automatically on multiple machines.

Edit your rc file using an editor of choice.

```{ .zsh .copy }
vim ~/.zshrc
```

Append this line to your shell's rc file or `fish.config` at the bottom.

```{ .bash .copy title="For bash .bashrc or zsh .zshrc" }
eval "$(flox activate -r youruser/example-project)"
```

```{ .fish .copy title="For fish config.fish" }
eval (flox activate -r youruser/example-project) | source
```

Don't forget to open a new terminal window or, for zsh, reload your RC file.

```{ .zsh .copy }
source ~/.zshrc
```

Now all new windows will open into your [FloxHub][floxhub_concept] environment. When you push changes from one machine, run `flox pull -r youruser/example-project` on other machines to get the latest updates.

## Sharing with containers

Flox can render that environment as an OCI container runtime suitable for use with containerd, Docker, Kubernetes, Nomad, and more.

Let's create a container image from the `example-environment` we have been working with.

To render your environment to a container, run `flox containerize`. This command
will automatically load the image into Docker:

```console
$ flox containerize --runtime docker # (1)!
...
Creating layer 1 from paths: [...]
...
Loaded image: example-project:latest
✨ Container written to Docker runtime
```

1. See [`flox containerize`][flox_containerize] for more output options.

!!! note "Why so many layers?"
    By default Flox splits every dependency into a different layers, which allows
    better dependency sharing and faster iteration.

Now let's run a command from our image:

```console
$  docker run --rm -it example-project -- telnet --version
telnet (GNU inetutils) 2.5
...
```

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Layering multiple environments][layering_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Customizing the shell hook][customizing_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Designing multiple architecture environments][multi_arch_guide]

[multi_arch_guide]: ./multi-arch-environments.md
[environment_concept]: ../concepts/environments.md
[layering_guide]: ./layering-multiple-environments.md
[customizing_guide]: ./customizing-environments.md
[flox_containerize]: ../man/flox-containerize.md
