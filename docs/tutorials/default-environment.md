---
title: The default environment
description: Using Flox as your system package manager
---

# The default environment

In the typical development case you would create a directory for your project.
`flox init` to create an environment for it,
then `flox activate` in that directory when you want to work on that project.
The packages in that environment are available when the environment is active,
and they're unavailable otherwise.
But what about packages that you _always_ want available?

Without Flox, you may turn to your system's package manager
(`apt`, `yum`, `brew`, etc)
in order to install packages system-wide.
This has a number of drawbacks:

- You often only have a single package version to choose from.
- You often can't install multiple versions side-by-side.
- You can't ensure that multiple machines get the exact same version.
- You may not be able to back up the list of installed packages.

The Flox `default` environment doesn't have these problems,
so let's take a look at how to set it up.

## Initial setup

At the most basic level, the `default` environment is simply an environment
called `default`.
`default` environments are typically [shared via FloxHub][floxhub-env];
We refer to the one associated with your account,
as _your_ `default` environment.

In some cases Flox will prompt to set up your `default` environment for you.
To create the `default` environment yourself,
make sure you are logged in to FloxHub,
and initialize a FloxHub environment under your account:

```{ .bash }
flox auth status || flox auth login
✅ Authentication complete
✅ Logged in as <youruser>

flox init -r <youruser>/default
```

Once the environment has been created,
you'll want to configure your shell to activate the environment with every new
shell.
This can be done as part of the automatic setup,
or you can add a single line to your shell's RC file:

=== "Bash"

    Depending on the context, Bash will load different startup files.
    For that reason, we need to add a line to two different files:
    `.bashrc` and `.profile`.
    Add the following line to the very end of each of those files:

    ```{ .bash .copy }
    eval "$(flox activate -r <your username>/default -m run)"
    ```

=== "Zsh"

    Add the following line to the very end of your `.zprofile` and `.zshrc`
    files:
  
    ```{ .zsh .copy }
    eval "$(flox activate -r <your username>/default -m run)"
    ```

=== "Fish"

    Add the following line to the very end of your `config.fish` file:

    ```{ .fish .copy }
    flox activate -r <your username>/default -m run | source
    ```

=== "Tcsh"

    Add the following line to the very end of your `.tcshrc` file:
  
    ** For FloxHub environments:**
  
    ```{ .tcsh .copy }
    eval "`flox activate -r <your username>/default -m run`"
    ```
  
---

Once you've added that line to your shell,
you'll need to restart your shell (or open a new one) for the changes to
take effect.
If you don't want to activate it automatically, the default
environment can simply be activated using `-d` parameter of the Flox CLI
like so:

```{ .bash .copy }
flox activate -r <your username>/default
```

## Taking it for a spin

Now let's test out your new `default` environment.
If you're in an arbitrary directory and `apt install hello` you would expect
it to be available no matter what directory you're in.
Let's do the same with Flox.

Let's create a new temporary directory that we know doesn't have an environment in it.

```{ .bash .copy }
cd $(mktemp -d)
```

Now we'll install a package and see that it gets installed to the `default`
environment,
like you would expect from your system's package manager:

```console
$ flox install hello
✅ 'hello' installed to environment 'default'
```

It worked (though you shouldn't be surprised; Flox is awesome)!

## Installing packages to the default environment from another Flox environment

If you're in a project directory with an existing Flox environment,
unsurprisingly, running `flox install <pkg>` will install the package
to the environment in that directory, rather than your default environment.

Nevertheless, it's still easy to install whatever you wish to your `default`
environment.
All you need to do is pass the `-d` argument to the `install` command, like so:

```{ .bash .copy }
flox install -r <your username>/default ~ hello
```

When you do this, you should see the following output, indicating success:

```console
✅ 'hello' installed to environment 'default'
```

## Customization

Depending on when you created your default environment
(the default was changed recently),
you may also see `flox [default]` as part of your prompt for every new shell.
You can configure that with a single command:

=== "Do show the Flox prompt"

    ```{ .bash .copy }
    flox config --set hide_default_prompt false
    ```

=== "Don't show the Flox prompt"

    ```{ .bash .copy }
    flox config --set hide_default_prompt true
    ```

---

## Sharing

Since the `default` environment is "just" another [FloxHub environment][floxhub-env],
it's possible to push this environment and share it between machines.

In fact, activating or initializing default environments on other machines
will link to the environment that is already on FloxHub.
To use the environment on other machines simply log in
and add the activation to your dotfiles as described above.

Changes made to the environment locally (e.g. newly installed packages) can be synchronized
with [`flox push`][push] and [`pull`][pull].

---

## Generations

Pushing an environment creates the first version of the environment tracked on
FloxHub, which is called a generation.

To see how generations can be used to undo changes, edit the environment,
perhaps adding a variable `FOO = "bar"` to the `[vars]` section.
Then push the environment to FloxHub:

```{ .sh .copy }
flox edit;
flox push
```

This should print a link to your environment on FloxHub.
Follow the link and click the `Generations` tab.
This should show the most recent generation created by the `flox edit` command.

To revert to the version of the environment prior to the edit, run rollback:

```{ .sh .copy }
flox generations rollback;
flox push
```

Now if you run `flox pull` on another host, you'll get the rolled-back
environment, without the edit.

---

## Conclusion

Whether you want a reproducible package manager for your whole system,
or you want reproducible, cross-platform developer environments,
Flox has you covered.
Even better, if you want both a package manager _and_ developer environments,
with Flox you only need to learn one tool.

---

## Detached and directory based `default` environments

Since `default` environments are normal Flox environments,
you can use any other environment the same way.

For example you can

=== "initialize a local environment e.g. in your home directory"

```{ .bash .copy }
flox init -d ~
```

=== "start with a template on FloxHub"

```{ .bash .copy }
flox pull --copy -d ~ owner/name
```

=== "use a directory based FloxHub environment"

```{ .bash .copy }
flox pull -d ~ owner/name
```

---

If you choose to automatically activate the environment in your rc files,
change the `flox activate -r <youruser>` accordingly
to e.g. `flox activate -d ~`.

[auth]: ../man/flox-auth.md
[init]: ../man/flox-init.md
[push]: ../man/flox-push.md
[pull]: ../man/flox-pull.md
[floxhub-env]: ./sharing-environments.md
