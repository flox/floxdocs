---
title: Package Groups
description: How package groups work and when to use them
---

# Package Groups

## What Are Package Groups?

**Package groups** (`pkg-group`) are one of the mechanisms Flox provides to manage dependency conflicts. Each package in a group resolves against the same [`nixpkgs`](https://github.com/nixos/nixpkgs) git commit; different package groups may resolve against different `nixpkgs` commits. This safeguards against runtime ABI incompatibilities and version conflicts.

Think of package groups as a convenient way to partition the resolver’s search space into discrete subproblems. They make it easier for the resolver to compute a functioning dependency graph.

Package groups are also useful as an **organizational tool**. You can use them to separate runtime dependencies, dev tools, and other categories of tooling into logical groupings in the [Flox environment’s manifest][environments-concept]. This makes environments with a large number of dependencies easier to read and maintain. In Flox [manifest builds][manifest-builds-concept], you can use package groups to keep dev-time tools out of the build context.

**tl;dr**: Define package groups when you need to install ABI- or version-incompatible sets of packages to a Flox environment. These are packages that need to pin to different commits in `nixpkgs`.


### A Canonical Example

```toml
[install]
openssl.pkg-path = "openssl"
curl.pkg-path = "curl"
```

The Flox [environment manifest](https://flox.dev/docs/concepts/environments/#environment-uses) above defines the `openssl` and `curl` packages. Flox resolves both against the same `nixpkgs` commit, selecting v3.6.1 of `openssl` and v8.18.0 of `curl`.

If you instead require a _specific version_ of one of these packages—say, v1.1.1q of `openssl`—but do not specify a version of `curl`, Flox resolves both packages to an older, compatible catalog revision. In this case, the environment pulls in a historical version of `curl`: v7.84.0, from June 2022, the same catalog revision that includes v1.1.1q of `openssl`, which was released the following month.

A problem arises if you require specific historical versions of both `openssl` _and_ `curl`. In such cases, the Flox resolver cannot always compute a coherent dependency graph. For instance, defining `openssl` v1.1.1q (June 2022) and `curl` v8.18.0 (January 2026) in the same environment triggers this error:

```bash
✘ ERROR: resolution failed: constraints for group 'toplevel' are too tight

   Use 'flox edit' to adjust version constraints in the [install] section,
   or isolate dependencies in a new group with '<pkg>.pkg-group = "newgroup"'
```

The solution is to isolate the `openssl` package in its own package group:

```toml
[install]
openssl.pkg-path = "openssl"
openssl.pkg-group = "legacy"
curl.pkg-path = "curl"
```


## Mental Model: The Same Package Group = The Same nixpkgs Commit

Every dependency in a package group gets pinned to the same historical `nixpkgs` commit. This means they were built and tested against the same set of packages. As a result, shared libraries (such as `glibc`, `libstdc++`, etc.) are the same across each group. This minimizes the risk of ABI incompatibilities.



## How Package Groups Work

### Default Group: `toplevel`

```d2 scale="0.9"
toplevel: "Group: toplevel" {
  packages: "bash, curl, git, jq"
  rev: "Catalog rev b40629e…\n(nixpkgs commit 2026-03-18)"
}

ml: "Group: ml" {
  packages: "python311, numpy, scipy"
  rev: "Catalog rev c5296fd…\n(nixpkgs commit 2025-07-22)"
}
```

When you install a package with `flox install`, it goes into **`toplevel`**, the default package group. `toplevel` is an **implicit** package group: any package installed without defining a `pkg-group` field gets placed into it.


```toml
[install]
bash.pkg-path = "bash"
git.pkg-path = "git"
curl.pkg-path = "curl"
jq.pkg-path = "jq"
```

All four packages above are in the implicit `toplevel` group and resolve against the same pinned `nixpkgs` commit. To place a package in a named package group, define the `pkg-group` key.

The three packages below are in the `ml` group and resolve against a historical `nixpkgs` commit:

```toml
python3.pkg-path = "python311Full"
python3.pkg-group = "ml"
numpy.pkg-path = "python311Packages.numpy"
numpy.pkg-group = "ml"
scipy.pkg-path = "python311Packages.scipy"
scipy.pkg-group = "ml"
```

`bash`, `git`, `curl`, and `jq` share the same `nixpkgs` commit (as members of `toplevel`), while `python3`, `numpy`, and `scipy` share another (as members of `ml`). These commits may be the same _or_ different: i.e., _if_ the `ml` packages are in fact satisfiable at the same `nixpkgs` commit as `toplevel`, _then_ the resolver selects that commit for both groups. The Flox resolver selects different `nixpkgs` commits only when one or more packages in a group actually require this. For this reason, you can use package groups to organize a Flox environment’s manifest, e.g., grouping related packages together for legibility.


### Resolution

When you run `flox install`, `flox edit`, `flox push`, `flox pull`, or `flox activate`, Flox attempts to resolve the environment and materialize its closure at `$FLOX_ENV` if it has not already done so.

During resolution, the Flox resolver performs the following actions for each package group:

1. **Collects constraints**. Gathers every package descriptor in the group (`pkg-path`, version constraints, system requirements).
2. **Searches catalog revisions**. Iterates through available `nixpkgs` revisions (newest first) to find a single revision where _all_ packages in the group can be satisfied.
3. **Applies per-package filters**. Checks `pkg-path` match, `version` constraint, `broken`/`unfree` flags, and `systems` constraint.
4. **Locks the result**. Writes every package entry to `manifest.lock` with the same `rev` and `locked_url`.

A `nixpkgs` commit is satisfying for a group if **every** package in the group has a matching version at that commit, across **all** target systems.

### Lock File Anatomy

The lock file (`manifest.lock`) records each resolved package with its group and `nixpkgs` commit. Below is an annotated excerpt showing two packages in different groups:

```json
{
  "lockfile-version": 1,
  "manifest": { "..." : "..." },
  "packages": [
    {
      "install_id": "git",
      "attr_path": "git",
      "version": "2.47.1",
      "group": "toplevel", // (1)!
      "rev": "b40629efe5d6ec48dd1efba650c797ddbd39ace0", // (2)!
      "locked_url": "https://github.com/flox/nixpkgs?rev=b40629e...",
      "rev_date": "2026-03-18T08:17:15Z",
      "system": "x86_64-linux",
      "priority": 5,
      "outputs_to_install": ["out"],
      "outputs": {
        "out": "/nix/store/...-git-2.47.1"
      }
    },
    {
      "install_id": "gum",
      "attr_path": "gum",
      "version": "0.17.0",
      "group": "tools", // (3)!
      "rev": "a1b2c3d4e5f6...", // (4)!
      "locked_url": "https://github.com/flox/nixpkgs?rev=a1b2c3d...",
      "rev_date": "2026-02-10T12:00:00Z",
      "system": "x86_64-linux",
      "priority": 5,
      "outputs_to_install": ["out"],
      "outputs": {
        "out": "/nix/store/...-gum-0.17.0"
      }
    }
  ]
}
```

1. Group assignment — all packages in the same group share the same `rev`
2. The catalog revision (nixpkgs commit) this group resolved to
3. Different group — may resolve to a different catalog revision
4. May differ from the `toplevel` group's revision

Things to note:

-  Every package in the same group shares the same `rev` and `locked_url`.
-  Each package has a **separate entry per system** (`x86_64-linux`, `aarch64-darwin`, etc.), but all entries for the same group share the same `rev`.
-  The `priority` field defaults to `5`. This is used to resolve file conflicts (lower value = higher priority).

**Note**: Without `pkg-group` or **`priority`** constraints, Flox attempts to resolve all defined packages into a dependency graph whose members can coexist within a single closure. Given a large number of packages, the set of `nixpkgs` commits capable of satisfying all dependency constraints becomes correspondingly narrow. In such cases, Flox typically resolves historical versions of packages rather than current-stable ones. We demonstrated this with `openssl` and `curl` in **A Canonical Example**.

This sometimes happens when only a few packages are defined in an environment. For example, if one package updates slowly—with months or years elapsing between releases—the resolver may need to pull in older versions of more frequently updated dependencies to produce a viable graph.


## When to Use Package Groups

### Isolating Packages with Tight Version Constraints

When a package requires a specific version that conflicts with versions needed by other packages in your environment:

```toml
[install]
python3.pkg-path = "python311Full"         # toplevel — latest available

torch.pkg-path = "python311Packages.torch"
torch.version = "~2.7.0"
torch.pkg-group = "ml"                  # isolated — may need an older nixpkgs rev
```

### Separating Optional Tooling from Core Dependencies

You can isolate dev tools in a separate package group so they don't constrain your core stack:

```toml
[install]
# Core runtime — version-sensitive
nodejs.pkg-path = "nodejs_20"
python311.pkg-path = "python311"

# Dev tools — version-insensitive, don't need to share a rev with core
bat.pkg-path = "bat"
bat.pkg-group = "devtools"

ripgrep.pkg-path = "ripgrep"
ripgrep.pkg-group = "devtools"

jq.pkg-path = "jq"
jq.pkg-group = "devtools"
```

### Cross-Platform Split

CUDA packages are only available on Linux. Placing them in their own group with a `systems` filter prevents resolution failures on macOS:

```toml
[install]
python3.pkg-path = "python313Full"

torch-cuda.pkg-path = "flox-cuda/python3Packages.torch"
torch-cuda.pkg-group = "cuda"
torch-cuda.systems = ["x86_64-linux", "aarch64-linux"]

torch-cpu.pkg-path = "python311Packages.torch-bin"
torch-cpu.pkg-group = "cpu-ml"
torch-cpu.systems = ["aarch64-darwin", "x86_64-darwin"]
```

### Resolving "Constraints Too Tight" Failures

When resolution fails with the error:

```
✘ ERROR: resolution failed: constraints for group 'toplevel' are too tight
```

This means no single catalog revision can satisfy all version constraints within the group. The fix is to split conflicting packages into separate groups:

```toml
[install]
# Before: everything in toplevel, resolution fails
# gcc.pkg-path = "gcc"
# gcc.version = "14.3.0"
# nodejs.pkg-path = "nodejs_20"
# nodejs.version = "20.11.0"

# After: split into groups, each resolves independently
gcc.pkg-path = "gcc"
gcc.version = "14.3.0"

nodejs.pkg-path = "nodejs_20"
nodejs.version = "18.18.2"
nodejs.pkg-group = "node"
```

## Practical Examples

### 1. Splitting Dev Tools from Runtime

A web application where runtime packages must be version-coherent, but linters and formatters can float independently:

```toml
[install]
# Runtime — all from the same rev
nodejs.pkg-path = "nodejs_20"
python311.pkg-path = "python311"
postgresql.pkg-path = "postgresql_16"
redis.pkg-path = "redis"

# Dev tools — separate group, independent resolution
prettier.pkg-path = "nodePackages.prettier"
prettier.pkg-group = "devtools"

shellcheck.pkg-path = "shellcheck"
shellcheck.pkg-group = "devtools"

nixfmt.pkg-path = "nixfmt-rfc-style"
nixfmt.pkg-group = "devtools"
```

### 2. ML Framework Isolation

A PyTorch inference serving project with several plugin groups, each pinned to its own `nixpkgs` commit:

```toml
[install]
python3.pkg-path = "python313"
python3.pkg-group = "dev"

torch.pkg-path = "flox-cuda/python3Packages.torch"
torch.pkg-group = "cuda-torch"
torch.systems = ["x86_64-linux", "aarch64-linux"]

numpy.pkg-path = "python313Packages.numpy"
numpy.pkg-group = "scientific"

scipy.pkg-path = "python313Packages.scipy"
scipy.pkg-group = "scientific"

transformers.pkg-path = "python313Packages.transformers"
transformers.pkg-group = "ml"

pillow.pkg-path = "python313Packages.pillow"
pillow.pkg-group = "ml"
```

Each group resolves independently, so updating `torch` doesn't force `numpy` or `transformers` to change.


### 3. Resolving File Conflicts with Priority and Groups

When two packages install files to the same path, use the `priority` field to control which package wins; use package groups so that they resolve from different revisions:

```toml
[install]
gcc.pkg-path = "gcc"

gcc-unwrapped.pkg-path = "gcc-unwrapped"
gcc-unwrapped.priority = 6              # lower priority than default (5)
gcc-unwrapped.pkg-group = "libraries"   # separate group to avoid version conflicts
```

The `priority` field defaults to `5`. Lower numbers win file conflicts. Here, `gcc` (priority 5) takes precedence over `gcc-unwrapped` (priority 6) for any overlapping files.


## Package Groups and Builds

### Only `toplevel` Packages Are Available During Flox Manifest Builds

When you use `flox build` with [manifest builds][manifest-builds-concept], only packages in the `toplevel` group are available as build dependencies. Packages in named groups are **not** accessible in build commands:

```toml
[install]
gcc.pkg-path = "gcc"                     # ✓ available during build (toplevel)
cmake.pkg-path = "cmake"                # ✓ available during build (toplevel)
python311.pkg-path = "python311"         # ✓ available during build (toplevel)

ripgrep.pkg-path = "ripgrep"
ripgrep.pkg-group = "tools"             # ✗ NOT available during build
```

This is by design: the build system aligns its nixpkgs input with the `toplevel` group's locked revision, ensuring the built package's dependencies are compatible with the environment's core packages.

**If a package is needed at build time, it must be in `toplevel`.**

### Trimming Runtime Closures

By default, every `toplevel` package becomes a runtime dependency of your build. Use `runtime-packages` to exclude build-only dependencies from the final closure:

```toml
[install]
clang.pkg-path = "clang"
bash.pkg-path = "bash"
pytest.pkg-path = "pytest"

[build.myapp]
command = '''
  make
  mv build/myapp $out/bin/
'''
runtime-packages = ["clang", "bash"]	# only clang and bash are kept at runtime; pytest is excluded
```

The `runtime-packages` list accepts `install-id` values (i.e., the key before `.pkg-path` in the `[install]` section’s TOML definition) from the `toplevel` group only.


## Upgrade Semantics

### Atomic Group Advancement

`flox upgrade` advances groups to newer catalog revisions. The key property: **all packages in a group move together** to the same new revision.

```bash
# Upgrade all groups
flox upgrade

# Upgrade only the "cuda" group
flox upgrade cuda

# Upgrade only the "toplevel" group
flox upgrade toplevel
```

Groups upgrade independently so advancing `cuda` to a newer revision doesn't change `toplevel` or any other group. Individual packages can be targeted by install ID only if they are the **sole member** of their group. If a group has multiple packages, you must upgrade the entire group.


### What Triggers a Change

An upgrade occurs when the resolver finds a newer catalog revision where the group's packages have changed in version, build configuration, or dependency graph. If nothing has changed, the group stays at its current revision.


## Troubleshooting

### "Constraints too tight"

**Symptom**: Resolution fails with:
```
resolution failed: constraints for group 'toplevel' are too tight
```

**Cause**: No single nixpkgs revision contains all requested package versions within the group.

**Solutions**:

1. **Loosen version constraints**. Change `version = "2.133.0"` to `version = "^2.133.0"` to accept semver-compatible versions.
2. **Split into package groups**. Isolate the conflicting package:
   ```toml
   kubectl.pkg-path = "kubectl"
   kubectl.pkg-group = "kubectl"
   ```
3. **Verify the package exists**. Use `flox search <pkg>` and `flox show <pkg>` to confirm the version is in the catalog.


### Non-`toplevel` Packages Missing During Builds

**Symptom**: A package you installed is not found when running `flox build`.

**Cause**: The package is in an explicit group, not `toplevel`.

**Fix**: Move it to `toplevel` by removing the `pkg-group` field, or add a duplicate entry in `toplevel` for the build:

```toml
[install]
# Available during build (toplevel)
cmake.pkg-path = "cmake"

# NOT available during build
cmake-extra.pkg-path = "cmake"
cmake-extra.pkg-group = "tools"          # this copy won't be seen by flox build
```

### Broken Packages Causing Silent Resolution Failures

Packages flagged as broken in nixpkgs are filtered out during resolution. If a package you expect to find isn't resolving, it may be broken at the `nixpkgs` commit the resolver is considering. Bypass with this filter:

```toml
[options]
allow.broken = true
```

Use this as a diagnostic step, not a permanent solution.


## Appendix A: Concept Mapping Between Flox and Nix

If you're familiar with Nix flakes, Flox package groups map directly to patterns you already know.

### Comparison Table

| Flox Concept | Nix Equivalent |
|---|---|
| Package group (single) | Pinned nixpkgs flake input at a specific rev |
| Multiple pkg-groups | Multiple nixpkgs inputs (`nixpkgs`, `nixpkgs-stable`) |
| `toplevel` default group | Primary `nixpkgs` input in a flake |
| Group upgrade (`flox upgrade`) | `nix flake update nixpkgs` (per-input) |
| `priority` | `meta.priority` in nixpkgs |
| Lock file group entries | `flake.lock` input nodes |
| Resolution failure ("constraints too tight") | No single nixpkgs rev satisfies all version pins |
| `outputs` / `outputs = "all"` | Derivation multi-output (`out`, `dev`, `lib`) |
| Catalog (Flox-specific) | Nixpkgs revision history (no direct Nix equivalent) |


### Side-by-Side: Flox Manifest vs. Nix Flake

**Flox manifest**: two package groups, resolved automatically:

```toml
# Flox manifest

[install]
gcc.pkg-path = "gcc"               # toplevel
cmake.pkg-path = "cmake"           # toplevel

python311.pkg-path = "python311"
python311.pkg-group = "scientific" # same group as numpy/scipy

numpy.pkg-path = "python311Packages.numpy"
numpy.pkg-group = "scientific"

scipy.pkg-path = "python311Packages.scipy"
scipy.pkg-group = "scientific"
```

**Equivalent Nix flake**: two nixpkgs `inputs`, manually discovered and pinned:

```nix
{
  inputs = {
    # Analogous to the "toplevel" group
    nixpkgs.url = "github:NixOS/nixpkgs/b40629efe5d6ec48dd1efba650c797ddbd39ace0";

    # Analogous to the "scientific" group
    nixpkgs-scientific.url = "github:NixOS/nixpkgs/c5296fdd05cfa2c187990dd909864da9658df755";
  };

  outputs = { self, nixpkgs, nixpkgs-scientific }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkgsSci = import nixpkgs-scientific { inherit system; };

      pythonSci = pkgsSci.python311.withPackages (ps: [
        ps.numpy
        ps.scipy
      ]);
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          # "toplevel" packages — all from the same nixpkgs rev
          pkgs.gcc
          pkgs.cmake

          # "scientific" packages — all from a different nixpkgs rev
          pythonSci
        ];
      };
    };
}
```

### What's Different

Package groups in Flox automate what is otherwise a manual process in Nix:

-  **Searching for compatible `nixpkgs` revisions**. Flox's resolver iterates through catalog revisions to find one that satisfies all constraints in a package group. In Nix, you can pin specific `nixpkgs` revisions yourself, but you must discover, choose, and maintain those pins explicitly.
-  **Resolution across target platforms**. Flox resolves a package group against all declared target systems. In Nix, support is typically modeled per-system in flake outputs and checked via builds or tests.
-  **Atomic upgrades**: The `flox upgrade` command advances a package group while keeping all packages in that group pinned to the same nixpkgs revision. In Nix, `nix flake update` advances pinned inputs in `flake.lock`; ultimately, however, compatibility is determined by the flake’s builds and checks.


## Appendix B: How Otherwise Incompatible Packages Coexist in a Single Flox Environment

If packages in different groups are pinned to dissimilar `nixpkgs` revisions—and potentially link against different versions of core libraries—how can they coexist in the same environment without conflicts?

The answer has to do with two properties of Nix and one property of Flox.


### 1. The Nix Store: Hash-Based Isolation

Every package built by Nix lives at its own SHA-256-hashed path in the Nix store:

```
/nix/store/<hash>-<name>-<version>/
```

The `<hash>` is derived from **all** of the package’s declared build inputs: source code, compiler, flags, and every dependency. This means that two versions of the same library—say, `openssl-1.1.1` and `openssl-3.1.7`—can coexist as two independent directories in `/nix/store`. They don't overwrite each other; they don’t even know about one another. There is no global `/usr/lib` that forces a single version.


### 2. RUNPATH: No Global Library Search

On most Linux systems, binaries find shared libraries via global paths like `/usr/lib` or `LD_LIBRARY_PATH`. Nix avoids this entirely.

During linking, Nix's `ld-wrapper` injects `RUNPATH` entries into each binary's ELF header. These entries are absolute store paths that point to the specific versions of libraries the binary was built against:

```
$ readelf -d /nix/store/...-curl-8.11.1/bin/curl | grep RUNPATH
  RUNPATH  /nix/store/...-openssl-3.0.15/lib:/nix/store/...-zlib-1.3.1/lib:...
```

Each binary hardcodes the specific Nix store paths to its own dependencies. There is no need for a `LD_LIBRARY_PATH` or `/usr/lib` fallback because every Nix-built binary knows precisely which version of which library to load at runtime. This means `Package A` can use `openssl-3.0.15` while `Package B` can use `openssl-1.1.1`, in the same environment, at the same time, on the same host. 

**Note**: Modern Nix uses `RUNPATH` (`DT_RUNPATH`), not `RPATH` (`DT_RPATH`). The practical difference: `RUNPATH` can be overridden by `LD_LIBRARY_PATH`, while `RPATH` cannot. In a Flox environment this likely won’t matter, but it is worth knowing if you're debugging with `ldd` or `LD_DEBUG`.


### 3. The Flox Environment: A Merged Symlink Forest

When Flox builds an environment, it materializes a single derivation that produces a directory of **symlinks** pointing into the Nix store. All packages from all groups get merged into this forest:

```
~/.flox/run/<env>/          # the environment's output
├── bin/
│   ├── git -> /nix/store/...-git-2.47.1/bin/git
│   ├── curl -> /nix/store/...-curl-8.11.1/bin/curl
│   └── gum -> /nix/store/...-gum-0.17.0/bin/gum
├── lib/
│   └── ...
└── share/
    └── ...
```

Package group boundaries are a **resolution-time** concept: i.e., they determine which `nixpkgs` revision each package is built from. In the materialized environment, package groups don't exist. Each package is simply one of many symlinks into the Nix store, irrespective of which group it belongs to.

File conflicts occur only when two packages expect to install a file to the **same relative path** (e.g., both provide `bin/python`). These are resolved by Flox’s `priority` key: lower numbers win. If two packages have equal priority and install different content to the same path, Flox reports a collision error.


### Why Package Groups Matter

Nix makes coexistence _mechanically possible_; package groups make it simple, declarative, and correct.

**Within a group**, all packages are pinned to the same `nixpkgs` git revision, so their shared dependencies are guaranteed to compatible. In other words, If two packages depend on `openssl`, they both get the same `openssl` package: the same version, the same store path, the same ABI.

**Across groups**, dependencies *can* differ, and Nix handles this gracefully: each binary finds its own libraries via `RUNPATH`. But packages that interact at runtime should share dependencies. For example:

- **Python extensions** must link against the same `libpython`. If `numpy` and `scipy` link against different `libpython` builds, importing both in the same interpreter will crash. Putting them in the same group guarantees they share the same `libpython`.
- **C/C++ libraries** that pass data structures between each other (e.g., `libcurl` calling into `openssl`) must agree on struct layouts and ABI. Same group guarantees this.

Package groups also improve the Flox resolver’s performance because it only needs to search for a compatible `nixpkgs` revision that satisfies all packages in a constrained set—i.e., the package group. Fewer packages per group means a smaller constraint-solving search space.

This makes it faster and less costly to resolve a coherent dependency graph.

[environments-concept]: ./environments.md
[manifest-builds-concept]: ./manifest-builds.md
