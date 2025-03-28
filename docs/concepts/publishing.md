---
title: "Publishing"
description: How to use Flox environments to build artifacts 
---

!!! tip "This is a Flox for Teams feature"

    This is a paid feature included with Flox for Teams.
    Sign up for [early access][early] if you are interested in accessing this feature.
  
Once you've built an artifact with the [`flox build`][builds-concept] command, you likely want to put it somewhere.
The `flox publish` command gives you the ability to upload artifacts to your private catalog so that they can be installed by anyone in your organization.

## Uploading an artifact

The `flox publish <name>` command allows you to upload an artifact built with the `flox build` command, where `<name>` is the name of any build listed in the `build` section of the manifest.

```toml
# manifest.toml
[build.mypkg]
command = '''
  ...
'''
```

```console
$ flox publish mypkg
```

## Publish process

In order to make sure that the uploaded artifact can be built reproducibly,
Flox imposes some constraints on the build and publish process.

- The Flox environment performing the build must tracked in a git repository.
- Tracked files in the git repository must be clean.
- The git repository has a remote defined, and the current revision has been pushed to it.
- The Flox environment must have at least one package installed to it.

All of this is there to ensure that the build environment isn't dirty and that we can associate the uploaded artifact with a point in time in the Base Catalog.
As a reminder, the Base Catalog is the built-in [catalog][catalog-concept] provided by Flox.

As part of the `flox publish` command, the CLI will clone the git repository to a temporary directory to ensure that any files referenced in the build are tracked by the repository.
A clean `flox build` is then run in this directory.

The package closure is then signed with the user-supplied signing key and uploaded to the organization's private catalog.

## The published payload

A published artifact consists of two parts:

- The artifact metadata
- The artifact itself

The artifact metadata is uploaded to Flox servers so that the Flox CLI can see that it's available via the `flox search`, `flox show`, and `flox install` commands.
The artifact itself is uploaded to a Catalog Store.

Today that store is user-provided, but a hosted offering will be provided in the future.
When the store is user-provided it means that your organization has complete control over your artifacts, and many organizations will still choose this route even when a hosted option is available.

## Consuming published artifacts

Once you have uploaded an artifact via `flox publish`, the package becomes available in `flox search`, `flox show`, and `flox install`.
To distinguish these packages from those provided by the Base Catalog, published packages are prefixed with the name of the organization.
For example, if your organization is called `myorg` and it publishes an artifact named `hello`, the artifact will appear as `myorg/hello` in the Flox CLI.

When a user runs `flox install myorg/hello`, the artifact is downloaded directly from the Catalog Store that it was published to.

By default, only the owner of the private catalog has access to artifacts published to it.
Individual users can be added to an allowlist able to access artifacts in the private catalog via the [catalog-util][catalog-util] command line tool.

## Configuration

### Catalog Store

The Flox CLI uses Nix under the hood to perform certain operations, and must be configured to be made aware of the user-provided Catalog Store.
A Catalog Store is an S3-compatible service.
See the "Catalog Store" cookbook page to learn more about how to provision the service.

### Signing key

Artifacts uploaded to a Catalog Store may be signed.
This key is provided to Flox via the `flox publish --signing-key` argument so that the key can be used to sign artifacts during the publish process.
Similarly, in order to install packages signed with this key, Nix must be configured to trust this key.
See the ["Catalog Store" cookbook page][catalog-store-cookbook] to learn more about how to configure Nix to trust the signing key.

[builds-concept]: ./manifest-builds.md
[early]: https://flox.dev/early/
[catalog-util]: https://github.com/flox/catalog-util
[catalog-concept]: ./packages-and-catalog.md
[catalog-store-cookbook]: ../cookbook/infrastructure/flox-store.md
