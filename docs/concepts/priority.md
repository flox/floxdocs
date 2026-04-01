---
title: Package Priority
description: How priority controls file conflict resolution in Flox environments
---

When multiple packages install a file to the same path,
Flox needs a rule to decide which one wins.
That rule is **priority**.

## How priority works

A Flox environment is a directory of symlinks
pointing into the Nix store.
When the environment is built,
every installed package's files are merged into this directory.
If two packages both provide `bin/python` or `share/licenses/LICENSE`,
their files collide.

Priority resolves these collisions:

- Every package has a `priority` value (default: **5**)
- **Lower numbers win**.
  A package with `priority = 1` takes precedence
  over a package with `priority = 5`
- If two packages collide at the **same priority**,
  Flox reports an error and the environment fails to build

Priority only affects files that actually collide.
Packages that install to non-overlapping paths coexist regardless
of their priority values.

## Setting priority

Set priority in the `[install]` section of your manifest:

```toml
[install]
gcc.pkg-path = "gcc"

gcc-unwrapped.pkg-path = "gcc-unwrapped"
gcc-unwrapped.priority = 6
```

Here `gcc` keeps the default priority of 5
and takes precedence over `gcc-unwrapped` (priority 6)
for any overlapping files.
Both packages are fully installed —
only the conflicting files are resolved in favor of `gcc`.

## When you need to set priority

Most packages don't conflict,
so you rarely need to think about priority.
The situations where it matters are:

### Overlapping packages

Some packages provide subsets or supersets of each other.
For example,
`gcc` and `gcc-unwrapped` both install some of the same files.
You may need both —
`gcc` for the compiler and `gcc-unwrapped.lib` for `libstdc++` —
but their overlapping files need a tiebreaker:

```toml
[install]
gcc.pkg-path = "gcc"

gcc-unwrapped.pkg-path = "gcc-unwrapped"
gcc-unwrapped.priority = 6
gcc-unwrapped.pkg-group = "libraries"
```

### CUDA packages

CUDA packages are a common source of collisions
because multiple packages install `LICENSE` files
to the same path.
When installing several CUDA packages,
assign incremental priorities:

```toml
[install]
cuda_nvcc.pkg-path = "flox-cuda/cudaPackages_12_8.cuda_nvcc"
cuda_nvcc.systems = ["aarch64-linux", "x86_64-linux"]
cuda_nvcc.priority = 1

cuda_cudart.pkg-path = "flox-cuda/cudaPackages.cuda_cudart"
cuda_cudart.systems = ["aarch64-linux", "x86_64-linux"]
cuda_cudart.priority = 2

cudatoolkit.pkg-path = "flox-cuda/cudaPackages_12_8.cudatoolkit"
cudatoolkit.systems = ["aarch64-linux", "x86_64-linux"]
cudatoolkit.priority = 3
```

The specific priority values don't matter
as long as each package gets a distinct number.
This tells Flox which `LICENSE` file to keep
when they collide.

### Cross-platform fallbacks

When providing platform-specific alternatives
(e.g. CUDA on Linux, CPU on macOS),
priority can indicate which variant is preferred
if both happen to be available:

```toml
[install]
cuda-torch.pkg-path = "flox-cuda/python3Packages.torch"
cuda-torch.systems = ["x86_64-linux", "aarch64-linux"]
cuda-torch.priority = 1

torch-cpu.pkg-path = "python311Packages.torch-bin"
torch-cpu.systems = ["x86_64-darwin", "aarch64-darwin"]
torch-cpu.priority = 6
```

In practice the `systems` filter already prevents collisions here,
but setting priority makes the intent explicit
and protects against future changes.

## Diagnosing collisions

When two packages collide at the same priority,
you'll see an error like:

```text
         > ❌ ERROR: 'cuda13.0-cuda_nvcc' conflicts with 'cuda13.0-libcublas'. Both packages provide the file 'LICENSE'
         > Resolve by uninstalling one of the conflicting packages or setting the priority of the preferred package to a value lower than '5'
```

To fix this,
identify which package should win for the conflicting path
and give it a lower priority number:

```toml
[install]
packageA.pkg-path = "packageA"
packageA.priority = 4

packageB.pkg-path = "packageB"
packageB.priority = 6
```

## Priority and package groups

Priority and [package groups][package-groups-concept]
solve different problems:

- **Package groups** control which `nixpkgs` revision
  each set of packages resolves against.
  They address version and ABI compatibility.
- **Priority** controls which package's file wins
  when two packages install to the same path.
  It addresses file-level collisions
  in the merged environment.

You can use both together.
For example,
`gcc-unwrapped` might need its own package group
(to resolve against a different `nixpkgs` revision)
_and_ a higher priority number
(to let `gcc` win file conflicts):

```toml
[install]
gcc.pkg-path = "gcc"

gcc-unwrapped.pkg-path = "gcc-unwrapped"
gcc-unwrapped.priority = 6
gcc-unwrapped.pkg-group = "libraries"
```

## Priority and builds

Priority has no effect on what is available
during [manifest builds][manifest-builds-concept].
Only packages in the `toplevel`
[package group][package-groups-concept]
are available during builds,
regardless of their priority.

If you use `runtime-packages` to trim your build's closure,
all listed packages are included at their assigned priorities.

## Priority and composition

When [composing environments][composition-concept],
the included manifests are merged before the environment is built.
If two environments define the same install ID
(e.g. both provide `gcc.pkg-path`),
the later environment's package descriptor overrides the earlier one
during the manifest merge —
this is a manifest-level override,
not a file-level priority collision.

After merging,
the resulting environment is built
and any file-level collisions between *different* packages
are resolved by priority
the same way they are in a non-composed environment.

## Reference

| Aspect | Detail |
| ------ | ------ |
| Default value | `5` |
| Direction | Lower number = higher precedence |
| Valid values | Integers (no fixed bounds) |
| Common range | `1` through `10` |
| Same-priority collision | Error — environment fails to build |
| Scope | File paths only — doesn't affect resolution |

### Nix equivalent

Flox's `priority` maps directly to `meta.priority` in nixpkgs.
The semantics are identical:
default value of 5, lower wins,
same-priority collisions produce errors.

Nixpkgs provides convenience wrappers —
`lib.meta.hiPrio` (sets priority to -10) and
`lib.meta.lowPrio` (sets priority to 10) —
but in Flox you set the integer directly in the manifest.

[package-groups-concept]: ./package-groups.md
[manifest-builds-concept]: ./manifest-builds.md
[composition-concept]: ./composition.md
