---
title: What is the Base Catalog?
description: Everything you need to know about the Base Catalog
---

# What is the Base Catalog

The base Catalog is the root of all packages in Flox.
It is generated from a fork of [nixpkgs][nixpkgs],
contains historical metadata
(such as versions and system support over time),
and is updated on an automated schedule.
When you install something with Flox,
it will come from
or will be built upon the Base Catalog data.

On a regular basis,
Flox will evaluate a subset of packages
from its [nixpkgs][nixpkgs] fork
and save the metadata from the evaluation.
This makes it available to users of Flox.

An addional process continously checks newly added packages
and records actual build information (narino) from `nixos.cache.org`.
This along, with considerations for packages flagged as _unfree_ and _broken_,
allows flox to make attempts to serve up known good builds.
If you encounter a difference between `flox show` (meta data only),
and what `flox install` gives you, it may be due to this logic.
Refer to `allow_broken`, `allow_unfree`, and `allow_missing_builds`
in the [environment manifest][manifest_concept] to override the defaults.

## Which packages does Flox evaluate?

Generally, Flox evaluates `legacyPackages.<system>.*`
and follows the `recurseForDerivations` attribute.
In addition to this,
some explicit paths are evaluated.
The following is the current set,
but is likely to change over time.

For all system types:

- `nodePackages`
- `rustPlatform.rustLibSrc`
- `nodePackages_latest`

Additionally for `darwin` system types:

- `darwin`
- `swiftPackages`
- `swiftPackages.darwin`

## Update schedule

Evaluating all of nixpkgs on every commit
of the nixpkgs repository
is computationally expensive and often unnecessary.
Instead, Flox ingests the equivalent of the nixos-unstable branch
on a daily basis.
This means that once a package has landed on nixos-unstable
you can expect it in the Base Catalog within a day.

It's important to note
that this is distinct from the time between merging a pull request on the nixpkgs repository
and when that package becomes available in the Base Catalog.
The nixpkgs repository performs a series of checks after merging a pull request,
and changes are merged into a series of different branches
as different checks are performed on the attributes (packages) changed by the pull request.
This process can take anywhere from a couple of days to over a week
depending on whether the change causes breakage
in other packages in the nixpkgs repository.

If you have submitted a pull request to nixpkgs
and are interested in tracking its progress,
you can use this site: [Nixpkgs PR Tracker][nixpkgs_tracker].

### Flox branches

Flox maintains a fork of [nixpkgs][floxpkgs]
and maintains several branches.
These branches
relate to a Flox concept of "stabilities"
that is not yet fully exposed.
These are not to be confused with upstream branches of the same name,
and all derive from the `unstable` branch
of our [fork][floxpkgs]
(which, again, is not the same thing as `nixos-unstable`).

- `unstable` is reset to upstream `unstable` daily
- `staging` is reset to the `unstable` branch of our [fork][floxpkgs] each Saturday
- `stable` is reset to the `staging` branch of our [fork][floxpkgs] on the first Saturday of the month
- `lts` is reset to the `stable` branch of our [fork][floxpkgs] on the first Saturday in January and July (every 6 months)

These "stability" channels
will be exposed in the future,
allowing users to select a varying frequency of updates.
This architecture
also allows for patches
and backporting of fixes
against all stabilities.

Note that these branches do NOT reflect upstream branches of similar name,
or release channels.
Backporting that occurs on those branches
is not yet available via Flox.

### Delays

Since the Flox Base Catalog is based on upstream `nixos-unstable`,
it is subject to any delays
that occur during the regular operations of the Nix ecosystem.
If there is breakage
or if an update causes significant rebuilds,
it may be deferred to a longer process
and further delay its arrival on `nixos-unstable`,
and subsequently in the Flox Base Catalog.

### Retention

Storage is not boundless
so Flox uses the stabilities to garbage collect
package metadata when new packages are added.
When a stability is updated,
a tag is created in the form of `<stabilty>.<date>`.
The last `N` tags of each stability are retained.
This means revisions may "fall out" of the catalog over time.
Existing lockfiles save the metadata and will work forever.
However, a `flox update` to an environment
that contins a specific version,
_may_ in the future fail to resolve.
In practice, with our retention settings,
this is very unlikely.
Weekly captures are generally sufficient
to capture every package change,
in effect keeping every version in the past 3 years availble.

Current settings:

- `unstable` - 180 tags (6+ months daily)
- `staging` - 156 tags (3 years weekly)
- `stable` - 60 tags (5 years monthly)
- `lts` - 12 tags (6 years bi-annual)

[nixpkgs]: https://github.com/NixOS/nixpkgs
[floxpkgs]: https://github.com/flox/nixpkgs
[nixpkgs_tracker]: https://nixpk.gs/pr-tracker.html
[manifest_concept]: ./environments.md#manifesttoml
