---
title: What is FloxHub?
description: Everything you need to know about FloxHub.
---

# What is FloxHub?

FloxHub is a cloud service that enables you to share your Flox
[environments][environments_concept].

## Account creation in FloxHub

When signing up for a FloxHub account,
we will **automatically use your GitHub username as the FloxHub account name**.

When you [`flox push`][flox_push] an environment to FloxHub,
you will be prompted to create an account.
You can return to FloxHub to view your environments any time at
[hub.flox.dev](https://hub.flox.dev).

### Authenticating with the CLI

You can authenticate with FloxHub from the Flox CLI.
Run [`flox auth login`][flox_auth] and follow the on-screen instructions.

## Working with Environments in FloxHub

### Environment page

The FloxHub Environment page allows you to **browse all the
[environments][environments_concept] you have shared** with
[`flox push`][flox_push].

You can also:

* **Search** for environments by name.
* **Filter** for compatible system types.

Once you have found an environment that interests you,
you can:

* Open the **Environment Details** page for the selected environment by
**clicking on the environment name**.
* Use the **Share button** to copy CLI sharing commands pre-populated with the
environment name.
* Use the **Delete button** to delete the environment from FloxHub.
* Use the **Generations shortcut button** to jump into the generations tab of
the Environment Detail page.

### Environment Detail page

The FloxHub Environment Detail page lets you verify the contents of your
environment and view its history in FloxHub.

* **Sidebar**: shows key facts about the environment's current generation, like
the number of packages, the systems supported, the active generation, and the
last modified date.
Below the key facts is a shortcut to the CLI sharing commands.
* **Current generation tab**: shows you packages that are in your
[environment's manifest][manifest_concept].
If your package was installed with a semantic version requirement,
that information will show on the right side.
* **Generation tab**: shows you the history of your environment through each
[generation][generation_concept].
Each new [`flox push`][flox_push] creates a new generation.
* **Change log tab**: describes the updates between each generation.
Packages that were installed with [`flox install`][flox_install] and uninstalled
with [`flox uninstall`][flox_uninstall] will be explicitly marked.
Packages that were added manually in a text editor or with
[`flox edit`][flox_edit] will show as "Manually edited".
* **Settings tab**: displays key information about your environment, like the
owner and its name.

## Referring to FloxHub environments

When referring to FloxHub environments to perform remote operations in the CLI,
you'll refer to the environment owner's account name, a forward slash `/`,
and the environment name.
Many commands use this syntax,
such as those that accept a `--remote` option,
and some commands such as [`flox pull`][flox_pull] that implicitly refer to
an environment on FloxHub.

``` console
$ flox pull example-owner/example-env
```

## Logging out of FloxHub

### Logging out in the web application

* Select the **portrait in the upper-right corner** of the screen
* Select **Log out** in the menu

### Logging out in the CLI

Run the [`flox auth logout`][flox_auth] command.

[flox_website]: https://flox.dev
[flox_push]: ../reference/command-reference/flox-push.md
[flox_pull]: ../reference/command-reference/flox-pull.md
[flox_activate]: ../reference/command-reference/flox-activate.md
[flox_auth]: ../reference/command-reference/flox-auth.md
[flox_edit]: ../reference/command-reference/flox-edit.md
[flox_install]: ../reference/command-reference/flox-install.md
[flox_uninstall]: ../reference/command-reference/flox-uninstall.md
[generation_concept]: ../concepts/generations.md
[manifest_concept]: ../concepts/environments.md#manifesttoml
[environments_concept]: ../concepts/environments.md
