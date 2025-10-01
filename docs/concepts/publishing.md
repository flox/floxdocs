---
title: "Publishing"
description: Understanding how to publish packages with Flox
---

Once you've built a package with the [`flox build`][flox-build] command, you likely want to _use_ it somewhere.
The [`flox publish`][flox-publish] command gives you the ability to upload packages to your private catalog so that you can _install_ them into your environments.
In order to share packages with other people you must create an organization.
See the [organizations][organizations-concept] page for more details.

## Uploading a package

The `flox publish <name>` command allows you to upload a package built with the `flox build` command, where `<name>` is the name of any build listed in the `build` section of the manifest.

```toml
# manifest.toml
[build.mypkg]
command = '''
  ...
'''
```

```{ .sh .copy }
flox publish mypkg
```

## Publish process

In order to make sure that the uploaded package can be built reproducibly,
Flox imposes some constraints on the build and publish process.

- The Flox environment performing the build must tracked in a git repository.
- Tracked files in the git repository must be clean.
- The git repository has a remote defined, and the current revision has been pushed to it.
- The Flox environment must have at least one package installed to it.

All of this is there to ensure that the published package can be locked to a point in time in the Base Catalog and an upstream source revision.
As a reminder, the Base Catalog is the built-in [Catalog][catalog-concept] provided by Flox.

As part of the `flox publish` command, the CLI will clone the git repository to a temporary directory to ensure that any files referenced in the build are tracked by the repository.
A clean `flox build` is then run in this directory.

If the build completes successfully, the package, its closure (all the software it depends on), and its metadata are uploaded to your Catalog.

## The published payload

A published package consists of two parts:

- The package metadata
- The package itself

The package metadata is uploaded to Flox servers so that the Flox CLI can see that it's available via the [`flox search`][flox-search], [`flox show`][flox-show], and [`flox install`][flox-install] commands.
The package itself is uploaded to a Catalog Store.

A Catalog Store is effectively a cache for published packages, and Flox provides one by default.
An organization can choose to provide their own Catalog Store in the form of an S3-compatible storage provider.
In this case, it means that your organization has complete control over your packages and they will never be stored by Flox.
To pursue this option, contact Flox directly.

## Consuming published packages

Once you have uploaded a package via `flox publish`, the package becomes available in `flox search`, `flox show`, and `flox install`.
To distinguish these packages from those provided by the Base Catalog, published packages are prefixed with the name of the user or organization.
For example, if your user is called `myuser` and you publish a package named `hello`, the package will appear as `myuser/hello` in the Flox CLI.

When a user runs `flox install myuser/hello`, the package is downloaded directly from the Catalog Store that it was published to.
If organizations configure their own Catalog Store (rather than using the default Catalog Store provided by Flox), it is never downloaded to or cached on Flox servers.

### Sharing

--8<-- "paid-feature.md"

Sharing packages with multiple users is only possible with an organization.
This means that individual users will not be able to share packages they've published with other users.

Packages can be published to an organization's catalog with
`flox publish --org <organization>`.
Packages published to an organization's catalog are visible to all other members
of the organization,
but they cannot be viewed by anyone outside the organization.
For anyone in the organization, published packages become available in
`flox search`, `flox show`, and `flox install`.

[builds-concept]: ./builds.md
[catalog-concept]: ./packages-and-catalog.md
[flox-build]: ../manual/flox-build.md
[flox-publish]: ../manual/flox-publish.md
[flox-search]: ../manual/flox-search.md
[flox-show]: ../manual/flox-show.md
[flox-install]: ../manual/flox-install.md
[organizations-concept]: ./organizations.md
