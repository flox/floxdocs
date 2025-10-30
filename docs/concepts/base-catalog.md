---
title: What is the Base Catalog?
description: Everything you need to know about the Base Catalog
---

# What is the Base Catalog

The base Catalog is the root of all packages in Flox.  It is generated from
a fork of [nixpkgs][nixpkgs], contains historical metadata (such as versions and system support over time), and is
updated on an automated schedule.  When you install something with Flox, it will come from or
will be built upon the Base Catalog data.

On a regular basis, Flox will evaluate a subset of packages from its
[nixpkgs][nixpkgs] fork and save the metadata from the evaluation.  This makes
it available to users of Flox.

## Which packages does Flox evaluate?

Generally, Flox evaluates `legacyPackages.<system>.*` and follows the
`recurseForDerivations` attribute.  In addition to this, some explicit paths are
evaluated.  The following is the current set, but is likely to change on a
regular basis.

For all system types:

- `nodePackages`
- `rustPlatform.rustLibSrc`
- `nodePackages_latest`

Additionally for `darwin` system types:

- `darwin`
- `swiftPackages`
- `swiftPackages.darwin`

## How often dose this happen

tldr; Flox ingests the equivalent of nixos-unstable on a daily basis.  So you
should expect Flox package availability to follow nixos-unstable by, at most,
about a day.

### Flox branches

Flox maintains a fork of [nixpkgs][floxpkgs] and maintains several branches.
These branches relate to a Flox concept of "stabilities" that is not yet fully
exposed in the UX.  These are not to be confused with upstream branches of the
same name, and all derive from the `unstable` branch of our fork[floxpkgs].

- `unstable` is reset to upstream `unstable` daily
- `staging` is reset to the `unstable` branch of our [fork][floxpkgs] each Saturday
- `stable` is reset to the `staging` branch of our [fork][floxpkgs] on the first Saturday of the month
- `lts` is reset to the `stable` branch of our [fork][floxpkgs] on the first Saturday in January and July (every 6 months)

These "stability" channels will be exposed in future versions allowing users to
select a varying frequency of updates.  This architecture also allows for
patches and backporting of fixes against all stabilities.

Note that these branches do NOT reflect upstream branches of similar name, or
release channels.  Backporting that occurs on those branches is not yet
available via Flox.

### Delays

Since the Flox Base Catalog is based on upstream nixos-unstable, it is subject
to any delays that occur during the regular operations of the nix eco-system.
If there is a breakage or if an update causes significant re-builds, it may be
deferred to a longer process and further delay it's arrival on nixos-unstable,
and subsequently in the Flox Base Catalog.

[nixpkgs]: https://github.com/NixOS/nixpkgs
[floxpkgs]: https://github.com/flox/nixpkgs
