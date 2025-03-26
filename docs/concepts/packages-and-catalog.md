---
title: What is the Flox Catalog?
description: Everything you need to know about the Flox Catalog and Packages.
---

# What is the Flox Catalog?

The **Flox Catalog** is a searchable index of **packages** that you can explore with
[flox search][flox_search], [flox show][flox_show], and then [flox install][flox_install] to your
environments.

It can also be consulted on https://hub.flox.dev/packages.

The built-in catalog contains a wide variety of open source packages you can use
in your environments.

A **package** is a collection of computer programs and related data that are
bundled for distribution together on a UNIX-based computer system.
Packages are declared in the [environment manifest][manifest_concept].

## Flox Catalog and nixpkgs

The Flox Catalog uses [nixpkgs][nixpkgs] as an input.
Upstream changes in [nixpkgs][nixpkgs] are reflected in the Flox Catalog daily from the unstable branch of [nixpkgs][nixpkgs].

## Supported package metadata

* **pkg-path**: unique location in the Flox Catalog.
* **version**: semantic version of the package.
* **license**: license metadata.
* **unfree**: indicates if the software uses a license not defined as Open
Source by the Open Source Initiative (OSI).
* **broken**: indicates if the package is marked as broken in
[nixpkgs][nixpkgs].

[flox_search]: ../reference/command-reference/flox-search.md
[flox_show]: ../reference/command-reference/flox-show.md
[flox_install]: ../reference/command-reference/flox-install.md
[flox_update]: ../reference/command-reference/flox-update.md
[manifest_concept]:./manifest.md
[nixpkgs]: https://github.com/NixOS/nixpkgs
