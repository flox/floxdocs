---
title: Flox in 5 minutes
description: Get started with creating Flox environments.
---

# Flox in 5 minutes

Flox is a virtual environment and package manager all in one.
With Flox you create development environments that layer and provide
dependencies just where it matters (Flox won't mess with your setup!),
making them portable across the full software lifecycle.

Follow the steps below to see how easy it is to get started with Flox.

## Quick start

1. [Install `flox`][install_flox].
1. Create a new environment with [`flox init`][init]
1. Search for `httpie` with [`flox search`][search]
1. Install `httpie`, `fx` and `jq` with [`flox install`][install]
1. Activate the environment with [`flox activate`][activate]
1. Make requests with `httpie`, inspect responses with `fx` and `jq`.
1. Push the environment to FloxHub with [`flox push`][push]
1. Delete the local environment with [`flox delete`][delete]
1. Activate the pushed environment with [`flox activate --remote`][activate]

Detail about each of these steps is below.

## Install Flox 

Start by [installing `flox`][install_flox].

## Create a new environment

Flox has features that will be familiar if you've used other package managers
before.
However,
Flox installs packages _into environments_ as opposed to installing
them into globally accessible directories across your entire system.

Let's create a new directory and create a new environment inside it with the
[`flox init`][init] command.
```
$ mkdir flox_project
$ cd flox_project
flox_project $ flox init
✨ Created environment flox_project (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
```

We see that we've created a new environment called `flox_project`,
where the name is taken from the name of the directory the project was created
inside of.
You can set the name during `init` with `flox init -n <name>`.
See the [`flox init`][init] command reference for more details.

We also see that the environment was created for the system type
`aarch64-darwin`,
which is the machine type of the laptop this command was run on.
This is another interesting Flox feature:
environments know about different types of systems!
This feature is part of the power of Flox and helps to ensure that your
environments work where you think they will.

For now let's look at some of the commands that the `init` message recommended.

## Searching for packages

We've created an environment,
so let's use [`flox search`][search] to find some packages to install into it.
We're going to do some API inspection,
so we'll need `httpie` to make requests.

Let's search for `httpie` using [`flox search`][search]
```
flox_project $ flox search httpie
httpie                         A command line HTTP client whose goal is to make CLI human-friendly
python310Packages.httpie       A command line HTTP client whose goal is to make CLI human-friendly
python311Packages.httpie       A command line HTTP client whose goal is to make CLI human-friendly
python310Packages.httpie-ntlm  NTLM auth plugin for HTTPie
python311Packages.httpie-ntlm  NTLM auth plugin for HTTPie

Use 'flox show <package>' to see available versions
```

The first result is `httpie`, the package we're looking for.

We also see the package `python311Packages.httpie`.
What's with the `.` in the name?
Flox provides software in the form of a [_catalog_][catalog].
Some software is provided at the top level of the catalog,
like `httpie`,
but other software is available under package sets,
like `python311Packages`.
In this case, `httpie` is provided both as a standalone executable,
but also as a Python module that can be installed and used within Python
scripts.

Let's move on to the next command.

## Installing packages

Let's install `httpie` with the [`flox install`][install] command.
You should see the following output,
where `<path>` is the absolute path to your environment.
```
flox_project $ flox install httpie
✅ 'httpie' installed to environment flox_project at <path>
```

## Activating the environment

If you didn't already have `httpie` installed,
when you run `which httpie` you'll see that the package isn't found:
```
flox_project $ which httpie
httpie not found
```

What gives?
Didn't we just install `httpie`?
Yes, but we installed it to our environment,
and we haven't _activated_ the environment yet.
This shows you that you can make changes to an environment without needing to
first activate it.

Let's activate the environment with the [`flox activate`][activate] command:
```
flox_project $ flox activate
✅ You are now using the environment flox_project at <path>.
To stop using this environment, type 'exit'

flox [flox_project] flox_project $
```

We see a message telling us that we've activated the environment named
`flox_project` that's located at `<path>`,
where again `<path>` is the absolute path to the environment.
We also see that our prompt has been modified to include the word `flox` and
the list of environments that are active (just `flox_project` in this case).

Now let's see what happens when we run `which httpie`:
```
flox [flox_project] flox_project $ which httpie
<path>/.flox/run/aarch64-darwin.flox_project/bin/httpie
```

The first thing to point out is that `httpie` is now found.
The second thing to point out is that there's a new `.flox` directory in
`flox_project`.
When you create an environment,
all of the metadata is stored in this `.flox` directory.
In practice you would want to add this directory to source control.

Something you should try while the environment is activated is using any
shell aliases or functions you've written for yourself.
Those still work!
If you were to work inside of a container all of the customizations you've made
for yourself wouldn't be available.

## Using the packages

Let's use `httpie` to make a request to a D&D 5th Edition API.
```
flox [flox_project] flox_project $ http get https://www.dnd5eapi.co/api/spells/fireball
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 1570
Content-Type: application/json; charset=utf-8
...
```
Great, the API is working, but that's a lot of output.

Let's install `fx`, a tool for interactively viewing JSON,
so that we can see how to extract the classes that can use this spell.
We'll also install `jq` so that we can extract just this part of the response
programmatically.

```
flox [flox_project] flox_project $ flox install fx jq
✅ 'fx' installed to environment flox_project at <path>
✅ 'jq' installed to environment flox_project at <path>
```

Now pipe the request to `fx` to explore the response.
Navigate using the `hjkl` keys, and use the `q` key to exit.
You should find this information under `.classes.name`.
```
flox [flox_project] flox_project $ http get https://www.dnd5eapi.co/api/spells/fireball | fx
```

Now let's use `jq` to extract this information for a different spell, `wish`.
```
flox [flox_project] flox_project $ http get https://www.dnd5eapi.co/api/spells/wish | jq '.classes[].name'
"Sorcerer"
"Wizard"
```

What this just demonstrated is that you can install packages to an
environment while it's active and they're immediately available,
no need to exit and reactivate the environment.
Speaking of exiting the environment, let's do that by typing `exit`.

```
flox [flox_project] flox_project $ exit
flox_project $
```

## What did Flox just do for you?

The `httpie`, `fx`, and `jq` packages are written in 3 different languages.
You didn't need to install any dependencies to run them,
and you didn't need to figure out where to put any files.

To make things even better,
now that you've exited the environment you should also be able to see that these
packages are no longer available.

```
flox_project $ which httpie
httpie not found
```

The packages in a Flox environment don't pollute your system when you aren't
using them.

## Sharing the environment

One of the most powerful features of Flox is the ability to share environments.
Let's push our new environment to FloxHub so that we can share it with other
people.

We'll run the [`flox push`][push] command to push our environment to FloxHub.
The first thing this will ask you to do is authenticate with FloxHub by entering
a code that it displays in the terminal.

```
flox_project $ flox push
You are not logged in to FloxHub. Logging in...
> First copy your one-time code: <code>

Press enter to open hub.flox.dev in your browser...
```

Copy the code and press Enter.
This will open your browser,
where you can enter the code and log in to FloxHub.
This will use GitHub to establish your identity,
but it won't grant Flox any permissions to read or write to any of your
repositories.
Once this is done you can return to your terminal and you should see the
confirmation message, where `<user>` is your GitHub username:

```
✅ Authentication complete
✅ Logged in as <user>
✅ flox_project successfully pushed to FloxHub

Use 'flox pull <user>/flox_project' to get this environment in any other location.
```

Let's test this out on our own system.
We're going to delete the local environemnt and activate the remote one.
Use the [`flox delete`][delete] command to delete the local environment:
```
flox_project $ flox delete
```
You should see a confirmation prompt asking if you're sure you want to delete
the environment.
```
flox_project $ flox delete
! You are about to delete your environment <user>/flox_project at <path>. Are you sure? (y/N)
[Use `-f` to force deletion]
```
Confirm the deletion.
If you run `ls -al`
you should see that the `.flox` directory is no longer there,
indicating that there's no longer an environment in this directory.

Now let's activate the environment that we just pushed:
```
flox_project $ flox activate --remote <user>/flox_project
✅ You are now using the environment <user>/flox_project (remote).
To stop using this environment, type 'exit'
flox [flox_project] flox_project $
```

You can see that confirmation message now says `(remote)` to indicate that the
environment you've activated is from FloxHub.
The prompt is also modified to show the activated environments just as before.

You can use the [`flox list`][list] command to see the packages installed to the
environment.
Let's do that to verify the environment we've activated has the same packages
as before:
```
flox [flox_project] flox_project $ flox list
fx: fx (31.0.0)
httpie: httpie (3.2.2)
jq: jq (1.7.1)
```

## But wait, there's more!

With this quick introduction we've only scratched the surface!
Flox environments have a number of other features that we haven't covered.

Environments are specified in a declarative TOML file called
[`manifest.toml`][manifest].
You can edit the declarative environment configuration using the
[`flox edit`][edit] command.

With activation scripts you can run commands every time the environment is
activated.
It's possible to set environment variables that are present in the
environment as well.
Activation scripts can use the environment variables that you've set.
These two features are particularly useful for performing initialization.

It's also possible to make certain packages available in the environment only
on certain types of systems
(e.g. install `gdb` on Linux, install `lldb` on macOS).

Have a look at the rest of the documentation to read more about all of the
features that Flox environments provide.

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } Try [**creating your first environment**][create_guide].

- :simple-readme:{ .flox-purple .flox-heart } Learn how to [**share and reuse** environments][share_guide].

- :simple-readme:{ .flox-purple .flox-heart } See **all the possibilities** for
[configuring your environment][manifest].

Learn how to [**share and reuse** environments][share_guide].

[install_flox]: ./install-flox.md
[create_guide]: ./tutorials/creating-environments.md
[share_guide]: ./tutorials/sharing-environments.md
[init]: ./reference/command-reference/flox-init.md
[search]: ./reference/command-reference/flox-search.md
[catalog]: ./concepts/packages-and-catalog.md
[install]: ./reference/command-reference/flox-install.md
[activate]: ./reference/command-reference/flox-activate.md
[edit]: ./reference/command-reference/flox-edit.md
[push]: ./reference/command-reference/flox-push.md
[delete]: ./reference/command-reference/flox-delete.md
[list]: ./reference/command-reference/flox-list.md
[manifest]: ./reference/command-reference/manifest.toml.md
