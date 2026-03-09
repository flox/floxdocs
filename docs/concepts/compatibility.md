---
title: Compatibility policy
description: Compatibility policy
---

Flox is a rapidly evolving tool, but you should still be able to rely on _some_ things being stable from release to release.

As of the 1.10.0 release, the Flox CLI is now schema-aware.
It will detect when modifications to the environment are backwards compatible, and will migrate your projects for you when changes aren't backwards compatible.

# Schema versions

Prior to CLI version 1.10.0, the manifest had a `version` field indicating the schema version of the manifest.
This field has been replaced with a `schema-version` field as of CLI version 1.10.0.

When a new manifest schema version is released, its schema version will be the version string of the CLI version that it was released with.
For instance, since CLI version 1.10.0 released the schema that contains this `schema-version` field, it would contain `schema-version = "1.10.0"`.
If a future CLI version X.Y.Z introduced a change to the manifest schema, it would introduce `schema-version = "X.Y.Z"`.

# Backwards incompatible changes

CLI version 1.10.0 introduced an `outputs` field for package descriptors so that you can specify exactly which parts of a package you want to include in your environment ([see here for more details](../tutorials/package-outputs.md)).
The previous manifest schema version (`version = 1`) doesn't support this field. That makes a manifest that contains `mypkg.outputs = "all"` backwards incompatible with a `version = 1` manifest.

On the other hand, nothing about the _other_ manifest sections changed (either in terms of semantics or adding/removing fields) between CLI versions 1.9.1 and 1.10.0. This means that editing the `hook.on-activate` script (for example) would be a backwards compatible change.

# Automatic migrations

When an edit to a manifest introduces a backwards incompatible change, the manifest will be automatically migrated to the latest schema version.
In all other situations, the manifest will be left at its original schema version.

For example, let's say that you're using a future CLI version X.Y.Z, and it introduces a new schema `schema-version = "X.Y.Z"`. Let's also say that the project you're working on contains a `version = 1` manifest. Updating the `hook.on-activate` script of your manifest is a backwards compatible change, so your manifest would be left at its current schema version (`version = 1`). Installing a package that has non-default outputs is a backwards _incompatible_ change (as of 1.10.0), so the manifest would be migrated to the latest schema version (`schema-version = "X.Y.Z"`).
