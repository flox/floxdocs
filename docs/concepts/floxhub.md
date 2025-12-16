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

!!! note "Note"
    If you need to share environments with a team, you can create an [Organization][organizations_concept] and push environments there instead of your personal account.

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

* **Sidebar**: shows key facts about the environment's live generation, like
the systems supported and the last modified date.
Below the key facts is a shortcut to the CLI sharing commands.
* **Details tab**: shows you packages that are in your
[environment's manifest][manifest_concept].
If your package was installed with a semantic version requirement,
that information will show on the right side.
* **Generation tab**: shows you the history of your environment through each
[generation][generation_concept].
Each new [`flox push`][flox_push] creates a new generation.
* **History tab**: describes the updates between each generation.
Packages that were installed with [`flox install`][flox_install] and uninstalled
with [`flox uninstall`][flox_uninstall] will be explicitly marked.
Packages that were added manually in a text editor or with
[`flox edit`][flox_edit] will show as "Manually edited".
* **Settings tab**: displays key information about your environment, like the
owner and its name.

### Automated upgrades

--8<-- "paid-feature.md"

To avoid missing important updates to your packages, it's a best practice to regularly upgrade your environments.
You can do this manually using the [`flox upgrade`][flox_upgrade] command or by clicking **Upgrade now** on the environment detail page in FloxHub.
However, if you have an [Organization][organizations_concept], you can let FloxHub upgrade your environments automatically.

#### Configure environment upgrades

Automated upgrades are enabled by default for all environments in an organization.
To change the default setting for an individual environment:

1. Sign in to [FloxHub][floxhub]
2. Choose an environment in an organization for which you're a *writer* or *owner*
3. Open that environment's detail page
4. Go to **Settings** > **Automated Upgrades**
5. Change the upgrade cadence to **Daily**

    !!! note "If you want to turn off automated upgrades, choose **Never**."

#### Organization-wide upgrade policy

You may choose to opt-out of automated upgrades for new environments, or turn them off for all environments in an organization.
To change your organization's upgrade policy:

1. Sign in to [FloxHub][floxhub]
2. Go to the detail page for an organization for which you're an *owner*
3. Go to **Settings** > **Automated Upgrades**
4. Select **Enable for new environments** to automatically upgrade new environments every day.
5. Select **Pause for all environments** to disable automated upgrades for all environments in this organization.

    !!! warning "We do not recommend disabling automated upgrades for all environments, as this can lead to outdated dependencies and potential security vulnerabilities."

## Referring to FloxHub environments

When referring to FloxHub environments in the CLI,
you'll refer to the environment owner's account name, a forward slash `/`,
and the environment name.
Many commands use this syntax with the `-r` flag (which operates on your local copy),
and some commands such as [`flox pull`][flox_pull] that implicitly refer to
an environment on FloxHub.
See the [FloxHub environments][floxhub_environments] concept page for more details on how local and upstream copies work.

```{ .sh .copy }
flox pull example-owner/example-env
```

## Logging out of FloxHub

### Logging out in the web application

* Select the **portrait in the upper-right corner** of the screen
* Select **Log out** in the menu

### Logging out in the CLI

Run the [`flox auth logout`][flox_auth] command.

[flox_website]: https://flox.dev
[flox_push]: ../man/flox-push.md
[flox_pull]: ../man/flox-pull.md
[flox_activate]: ../man/flox-activate.md
[flox_auth]: ../man/flox-auth.md
[flox_edit]: ../man/flox-edit.md
[flox_install]: ../man/flox-install.md
[flox_uninstall]: ../man/flox-uninstall.md
[flox_upgrade]: ../man/flox-upgrade.md
[generation_concept]: ../concepts/generations.md
[manifest_concept]: ../concepts/environments.md#manifesttoml
[environments_concept]: ../concepts/environments.md
[organizations_concept]: ../concepts/organizations.md
[floxhub]: https://hub.flox.dev
[floxhub_environments]: ./floxhub-environments.md
