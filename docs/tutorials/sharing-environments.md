---
title: Sharing your environments
description: Multiple ways to share your environment with others.
---

# Sharing your environments

Flox provides **three main ways of sharing environments** with others:

- **Sharing environments with files:**: Flox environments are shared via the `.flox` folder and often checked into version control.
- **Sharing environments on FloxHub**: Flox environments are shared via FloxHub and available to all `flox` commands with `-r username/environment`. Commands operate on your local copy; use `flox push` to sync changes to FloxHub.
- **Containers**: Flox environments are used to create container images.

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
$ flox install nodejs mkcert
✅ 'nodejs' installed to environment example-project at /Users/youruser/example-project
✅ 'mkcert' installed to environment example-project at /Users/youruser/example-project
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

Instead of sharing environments with files, you can share them on
[FloxHub][floxhub_concept] with a free account, which eliminates the need to
clone a repository when using the environment.

Once an environment has been pushed to FloxHub, it can be used in number of
different workflows:

- You can `flox pull --copy` an environment to [use it as a template for a new project](composition.md#creating-a-template-for-new-projects).
- You can use it directly in other environments by [adding it to another environment's `[include]` section](composition.md#composing-environments).
- You can use it to share software across multiple machines, most commonly with a default environment, by [adding it to your terminal's RC files](default-environment.md#initial-setup).
- Finally, you can use it to materialize an ad-hoc set of tools, which we'll show here.

To create an environment on FloxHub, first use `flox init` to create it locally:

```console
$ mkdir llm_tools
$ cd llm_tools
$ flox init
$ flox install codex gemini-cli
✅ 'codex' installed to environment llm_tools at /Users/youruser/llm_tools
✅ 'gemini-cli' installed to environment llm_tools at /Users/youruser/llm_tools
```

Then push it:

```console
$ flox push
✅  llm_tools successfully pushed to FloxHub

    Use 'flox pull youruser/llm_tools' to get this environment in any other location.
```

You can also view your new environment on FloxHub.

### Using a local copy of a FloxHub environment

Suppose you've dropped into a shell on another host or in a container, and you need to use a tool not on that host.
To activate your FloxHub environment, run:

```console
$ flox activate -r youruser/llm_tools
✅ You are now using the environment 'llm_tools'
To stop using this environment, type 'exit'
$ # ask gemini a question
```

This will implicitly pull the environment and create a local copy of the environment if it doesn't already exist.

### Pulling a FloxHub environment into a directory (and pushing updates)

If you intend to commit the environment to version control, you may want to [`flox pull`][flox_pull] it instead.

[`flox pull`][flox_pull] adds a `.flox` folder to the directory you are in that is linked to the FloxHub environment. When using a [FloxHub][floxhub_concept] environment in multiple projects it allows centralized management of the dependencies used across these projects. Run `flox pull` to sync the latest changes from FloxHub:

```console
$ cd similar-example-project
$ flox pull youruser/example-project
✨  Pulled youruser/example-project from https://hub.flox.dev

    You can activate this environment with 'flox activate'
```

After pulling an environment you can install changes to it locally and, when you're ready, [`flox push`][flox_push] them to FloxHub if you have permissions:

```console
$ flox install yarn
✅ 'yarn' installed to environment youruser/example-project at /Users/youruser/similar-example-project
$ flox push
✅  Updates to example-project successfully pushed to FloxHub

    Use 'flox pull youruser/example-project' to get this environment in any other location.
```

!!! note "Note"
    Right now, only environment owners can push edits to their environments.

[flox_push]: ../man/flox-push.md
[flox_pull]: ../man/flox-pull.md
[flox_activate]: ../man/flox-activate.md
[floxhub_concept]: ../concepts/floxhub.md

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
