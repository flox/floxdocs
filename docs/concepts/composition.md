---
title: Composing environments
description: How to combine and reuse environments.
---

# Composing environments

When your company starts work on a new service, it's likely that the tools required to work on this service will be very similar to the tools used to work on other services at the company.
Similarly, when you work on hobby projects it's likely that you use a similar set of tools from one project to the next.
With other developer environment solutions it's common to need to recreate your developer environment from scratch for each new project.

With Flox you can define a toolchain or service once and _compose_ it with others to create a composed environment.
Put another way, **with Flox you can create developer environments from reusable building blocks**.
Reuse and composition are two features that have long been a Holy Grail for developer environments, and Flox makes these features friendly and easily accessible.

## Building blocks

Environments are the building blocks from which a "composed" environment is created.
In this composition there is a hierarchy consisting of a "composing" environment and a list of "included" environments that it treats as dependencies.
The manifests of the included and composing environments are merged and then the resulting "merged" manifest is locked and built.

```d2 scale="0.9"
composer: "Composing\nenvironment"

includes: Included environments {
  envA: Env A
  envB: Env B
  envC: Env C
  direction: down
  envA -> envB: Overridden by
  envB -> envC: Overridden by
}

includes -> composer: Overridden by
```

## Including an environment

The included environments are declared in your manifest in the `include` table under the `environments` array.
Each entry in this array is an "include descriptor", which specifies where to find the environment.

```text
IncludedEnvironments ::= [IncludeDescriptor]
IncludeDescriptor ::= LocalIncludeDescriptor | RemoteIncludeDescriptor
LocalIncludeDescriptor :: = {
  dir  = STRING
, name = null | STRING
}
RemoteIncludeDescriptor :: = {
  remote = STRING
, name   = null | STRING
}
```

Just like you would use the `flox activate --dir` flag to specify an environment to activate by its path, you use the `dir` field to specify the path to an environment to include.
Every environment has a name built-in, but sometimes there may be name conflicts, or you may just want to provide a different name.
You can do so with the `name` field.

An example `include` section is shown below:

```toml
[include]
environments = [
  # Include a local environment
  { dir = "../myenv" },
  # Override the name of an environment
  { dir = "../other_env", name = "other" },
  # Include a remote environment
  { remote = "myuser/myenv" },
]
```

The order in which the included environments are listed matters.
The environments specified later in the list will override those earlier in the list.

It is possible to push a composed environment to FloxHub, but not if it includes environments that exist locally e.g. environments that are specified with the `dir` field.

## Merging process

When environments are composed, their manifests are merged into a single merged manifest.
The manifests are merged, and the merged manifest is locked (as opposed to building the environments and merging their lockfiles).
This allows manifests to override each other e.g. to ask for a newer version of a package specified in an earlier manifest in the merge process.

Later manifests override earlier manifests when there are conflicts, and the manifest of the composing environment always has the highest priority (it is applied last).
The `include.environments` array is stripped from included environments and the composing environment's manifest during the merge process.

The manifests are merged during the process of building the environment, and if one manifest overrides another, a warning is displayed.

Most manifest fields are merged the way you would expect:

`install`

:  The install section contains the union of all package descriptors from all manifests. When there are conflicts, the entire package descriptor is overridden.

`services`

: Same behavior as the `install` section.

`vars`

: Same behavior as the `install` section.

`hook.on-activate`

: The `hook.on-activate` scripts are appended to each other.

`profile`

: The corresponding scripts in the `profile` section are also appended to each other e.g. all of the `profile.common` scripts are appended, all of the `profile.bash` scripts are appended, etc.

`containerize`

: The options in the `containerize` section are more complicated because merging some options instead of overriding them would lead to unintuitive behavior.
`user`, `cmd`, `working-dir`, and `stop-signal` are completely overridden.
`exposed-ports`, `volumes`, and `labels` are merged.

`options`

: The options in the `options` section are all overridden completely.
This prevents a merge of `options.systems` from providing more systems than the environment can support.
Similarly, this prevents a merge of `allow.licenses` from allowing more licenses than intended.

One option to note is `options.activate.mode`.
Recall that the activation mode determines whether development dependencies of packages are added to `PATH`, etc when the environment is activated.
Since the default is `dev` mode, and the default doesn't appear in the manifest, a single environment that sets `options.activate.mode = "run"` will cause the merged manifest to also set this option.
This can be surprising, so check the manifests of the included environments and override this option if you're observing this behavior.

## Getting the latest manifests

It's reasonable to assume that the manifests of the included environments will change over time and at some point you will want to bring in the latest versions of those manifests.
This is accomplished with the `flox include upgrade` command.

Running this command will check each of the included environments and check if the environments have changed.
In order for changes to be pulled in, the included environment must have a lockfile corresponding to the latest changes to the manifest.
For example, suppose an environment `my-go-project` includes a `go-tools` environment.
If the `manifest.toml` for `go-tools` is modified without using `flox edit`, then `flox include upgrade` for `my-go-project` won't be able use the changes to the `go-tools` manifest.
Using `flox edit` for `go-tools` would re-lock the environment using the latest manifest, and then `flox include upgrade` for `my-go-project` could pull in the changes.
At this point the merge process runs again, a new merged manifest is produced, and the composed environment is rebuilt from the new merged manifest.
