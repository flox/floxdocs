---
title: What is the Flox Catalog?
description: Everything you need to know about the Flox Catalog and Packages.
---

# What is the Flox Catalog?

A Flox Catalog is a collection of package artifacts and associated metadata that can be consumed via a Flox Environment. The contents of a catalog can be searched, shown, and installed into an environment by way of the [flox search][flox_search], [flox show][flox_show], and then [flox install][flox_install] commands.

There are two types of catalogs:

The Base Catalog is populated by Flox and contains packages over time as maintained by the Nix Community by way of The [Nixpkgs](https://github.com/nixos/nixpkgs) Collection.

Custom Catalogs are maintained by the Users and Organizations that own them by way of the `flox publish` command, as described in the [Build][builds] and [Publish][publishing] concept pages.

The visibility of Custom Catalogs can be public or private, and packages from all types of catalog are consumed by way of the same flox (search|show|install) commands.

It can also be consulted on [https://hub.flox.dev/packages](https://hub.flox.dev/packages).

A **package** is a collection of computer programs and related data that are
bundled for distribution together on a UNIX-based computer system.
Packages are declared in the [environment manifest][manifest_concept].

## Base Catalog and nixpkgs

The built-in catalog is called the Base Catalog, and contains a wide variety of open source packages you can use in your environments.
The Base Catalog uses [nixpkgs][nixpkgs] as an input.
Nixpkgs is a community maintained project, but the Base Catalog is maintained by Flox.
Upstream changes in [nixpkgs][nixpkgs] are reflected in the Flox Catalog daily from the `unstable` branch of [nixpkgs][nixpkgs].

## Supported package metadata

* **pkg-path**: unique location in the Flox Catalog.
* **version**: semantic version of the package.
* **license**: license metadata.
* **unfree**: indicates if the software uses a license not defined as Open
Source by the Open Source Initiative (OSI).
* **broken**: indicates if the package is marked as broken in
[nixpkgs][nixpkgs].

[flox_search]: ../man/flox-search.md
[flox_show]: ../man/flox-show.md
[flox_install]: ../man/flox-install.md
[flox_update]: ../man/flox-update.md
[manifest_concept]: ./environments.md#manifesttoml
[nixpkgs]: https://github.com/NixOS/nixpkgs
[builds]: ./builds.md
[publishing]: ./publishing.md
