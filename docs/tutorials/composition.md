---
title: Reusing and combining developer environments
description: How to build developer environments out of reusable building blocks.
---

# Reusing and combining developer environments

It's common to use a very similar set of tools from one project to the next, but it's also very common to need to set up a developer environment from scratch from one project to the next.
In this tutorial you'll see how to significantly cut down on the work required to bootstrap new projects.

## Create a reusable toolchain

Let's say that you frequently work on Python projects and use [Poetry][poetry] as your package manager of choice.
If you work on a bunch of projects that need these tools, you can save yourself some time by creating an environment that contains `python312` and `poetry` and reusing it in some way.
Let's do that now and we'll show you some examples of different ways you can reuse it.

Create a new directory called `myproject` and `cd` into it.
Then create a new environment called `python_env` in it with the [`flox init`][flox-init] command.

```
$ mkdir myproject && cd myproject
$ flox init -d python_env
✨ Created environment 'python_env' (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
  $ flox edit                <- Add environment variables and shell hooks
```

Your directory structure should now look like this:

```text
myproject/
  python_env/
    .flox
```

Now install `python312` and `poetry` to this environment with the [`flox install`][flox-install] command:

```
$ flox install -d python_env python312 poetry
✅ 'python312', 'poetry' installed to environment 'python_env'
```

Now you can push this environment to [FloxHub][floxhub].
Once the environment is on FloxHub you can share it with other people, but, more importantly, you can now use it as a template for new projects.
Let's start by pushing the environment to FloxHub:

```
$ flox push -d python_env
✅ python_env successfully pushed to FloxHub

Use 'flox pull myuser/python_env' to get this environment in any other location.

This environment is public.
You can view and edit the environment at https://hub.flox.dev/myuser/python_env
```

You may need to authenticate with FloxHub as part of running this command.
Instead of `myuser` you will see your username.

## Template environments

### Creating a template for new projects

Now that the environment is on FloxHub, we can use it to bootstrap new projects.
One way to do this is to make a new, local copy of the environment that's not connected to FloxHub.
You accomplish this with the [`flox pull --copy`][flox-pull] command.
Let's create a new copy of this environment in a directory called `new_python_project`:

```
$ flox pull -d new_python_project --copy myuser/python_env
✨ Created path environment from myuser/python_env.

You can activate this environment with 'flox activate'
```

Your directory structure should now look like this:

```
myproject/
  python_env/
    .flox/
  new_python_project/
    .flox/
```

At this point your `new_python_project` directory contains a Flox environment that already contains Python development tools, and you're ready to start developing.

### Staying in sync with the template

By using the `--copy` flag to `flox pull` we have created a new copy of the environment that is completely disconnected from the copy on FloxHub.
This makes sense if you plan to add project-specific dependencies, otherwise your template environment would accumulate dependencies not needed by _all_ of your Python projects.
The downside is that if someone makes changes to the template environment, your local copy won't get those updates.

In some cases, however, you may actually want your project to stay in sync with the template.
If that's something you want, you can simply omit the `--copy` flag and periodically run the `flox pull` command to get the latest updates to the environment.
This amounts to using the template environment directly.

## Composing environments

### Creating a composed environment

In the previous example we showed you how you could create a local copy of a template environment (and lose access to updates), _or_ use the template environment directly (and either stuff it full of every project's dependencies, or not add dependencies to it at all).
What if I told you that you could have the best of both worlds?
We call this feature "composition".

One environment (we call it the "composing" environment) can "include" another environment (we call this an "included" environment), treating it like a dependency.
You can install packages to the composing environment just like you would any other environment, which allows you to reuse the template environment, get updates to it, and add project specific dependencies directly to the composing environment.

Let's see an example of this in action.
As a reminder, you currently have this directory structure:

```
myproject/
  python_env/
    .flox/
  new_python_project/
    .flox/
```

Let's create a environment in a `composer` directory.

```
$ flox init -d composer
✨ Created environment 'composer' (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
  $ flox edit                <- Add environment variables and shell hooks
```

Your directory structure should now look like this:

```
myproject/
  python_env/
    .flox/
  new_python_project/
    .flox/
  composer/
    .flox/
```

Pretend that this is the environment you would use to do your work on your Python project.
You're going to need a Python toolchain, and you may need some additional dependencies.
In order to bring in the Python toolchain we'll need to edit the manifest of the `composer` environment and include the `python_env` environment.
Run the [`flox edit`][flox-edit] command and make the `include` section of the manifest look like this:

```toml
[include]
environments = [
  { dir = "../python_env" }
]
```

This `include.environments` list tells the Flox CLI where to find the environments you'd like to include.
When there is more than one environment in this list, the order of the environments in the list also specifies their priority (later ones in the list have higher priority).
Once you save and exit you should see this output:

```
✅ Environment successfully updated.
ℹ The following manifest fields were overridden during merging:
- This environment set:
  - options.systems
ℹ Run 'flox list -c' to see merged manifest.
```

As part of building the composed environment, the manifests of the included environments and the composing environment are merged, which means that some environments may install the same package, set the same environment variable, etc.
In those cases, the priority order of the environments determines which one wins, with the composing environment always having the highest priority.
When one manifest overrides another, you are shown a message indicating which fields were overridden so that there are no surprises.
The message about `options.systems` is simply a result of the fact that the default manifest sets this field explicitly.

If you now run [`flox list`][flox-list], you should see the packages from the `python_env` environment, even though we never ran a `flox install` command on the `composer` environment!

```
$ flox list -d composer
poetry: poetry (2.1.1)
python312: python312 (python3-3.12.9)
```

Remembering that as part of the build process we merge manifests, if you want to see the final merged manifest you can use the `flox list -c` command.
When you use this command _without_ a composed environment, it prints the (unmerged) manifest.
When you use this command _with_ a composed environment, it prints the merged manifest.

```
$ flox list -c -d composer
version = 1

[install]
poetry.pkg-path = "poetry"
python312.pkg-path = "python312"

[options]
systems = ["aarch64-darwin", "aarch64-linux", "x86_64-darwin", "x86_64-linux"]

ℹ Displaying merged manifest.
ℹ The following manifest fields were overridden during merging:
- This environment set:
  - options.systems
```

Notice that the `[install]` section contains the `python312` and `poetry` packages that were merged in from the `python_env` environment.

### Installing project specific dependencies

Now let's install some project-specific dependencies.
When you run the `flox install` command on a composing environment, the packages are installed to the composing environment itself, not the merged manifest or any of the included environments.
In short, it does what you would expect.

Let's add the `pytest` package:

```
$ flox install -d composer python312Packages.pytest
✅ 'pytest' installed to environment 'composer'
```

Note that the message says the package was installed to the `composer` environment.
If you run `flox edit -d composer` you'll see that the package is contained in the `[install]` section of `composer`'s manifest.

### Getting the latest versions of included environments

At some point a template environment may change.
Say that you decide you want to use [hypothesis][hypothesis] for testing all of your Python projects.
To do that, you would install the `hypothesis` package to your `python_env` environment, and somehow propagate those changes to the composed environment.
This is accomplished with the `flox include upgrade` command, which fetches the latest versions of each of the included environments.

Let's add that package to `python_env`:

```
$ flox install -d python_env python312Packages.hypothesis
✅ 'hypothesis' installed to environment 'myuser/python_env'
```

Now let's propagate those changes to the composed environment:

```
$ flox include upgrade -d composer
✅ Upgraded 'composer' with latest changes to:
- 'python_env'
```

Now if you run `flox list` you should see that the composed environment now contains the `hypothesis` package:

```
$ flox list -d composer
hypothesis: python312Packages.hypothesis (6.127.4)
poetry: poetry (2.1.1)
pytest: python312Packages.pytest (8.3.5)
python312: python312 (python3-3.12.9)
```

Remember, the only package that's installed to `composer` directly is `pytest`.
All of the other packages you get for free just by including the `python_env` environment.

## Conclusion

The ability to reuse and combine environments means that you can now assemble a developer environment for a project from reusable building blocks.
This means you can spend less time getting started, and more time developing your software.
Similarly, since you're treating environments like dependencies, if you make an improvement to a template environment while working on one project, the improvement will become available to all of your other projects that use that environment as soon as they run `flox include upgrade`.

[poetry]: https://python-poetry.org/
[flox-init]: ../reference/command-reference/flox-init.md
[flox-pull]: ../reference/command-reference/flox-pull.md
[flox-install]: ../reference/command-reference/flox-install.md
[flox-edit]: ../reference/command-reference/flox-edit.md
[flox-list]: ../reference/command-reference/flox-list.md
[floxhub]: ../concepts/floxhub.md
[hypothesis]: https://hypothesis.readthedocs.io/en/latest/
