---
title: Node.js
description: Common questions and solutions for using Node.js with Flox
---

# Node.js

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

### Manifest builds

#### npm

Building Node.js packages with `npm` looks similar to building for containers or serverless functions.
On a high level, builds for Node.js-based projects generally follow this pattern:

```toml
[build.myproject]
command = '''
# Install dependencies
npm ci

# Build
npm run build
# -> assuming this yields a `dist` directory

# Install the build result to `out` # (1)!
mkdir -p $out
mv ./dist $out/

## If your app does not use a bundler
## and needs additional node_modules at runtime,
## `npm prune` and copy the node modules to $out
#
# npm prune --include "prod"
# cp -r ./node_modules $out

# Create a run script # (2)!
mkdir -p $out/bin
echo "#!/usr/bin/env sh"
echo 'exec node $out/dist/index.js "$@"' >> $out/bin/myproject
chmod 755 $out/bin/myproject
'''
```

1. If you expect to install multiple Node.js applications in the same environment, we recommend putting the `dist` (and optional `node_modules`) under an appropriate namespace, e.g. install them as `/libexec/myproject/dist`.

2. If your `npm build` already produces a binary that can be executed drectly, you can also copy or link that to `$out/bin`. Note that only binaries in `$out/bin` are wrapped to ensure they run within a consistent environment.

#### Vendoring dependencies in pure builds

As discussed in the [pure builds][pure-builds-section] of the Builds concept page, pure builds run in a sandbox without network access on Linux.
A pure build can be run as a multi-stage build where the first step vendors dependencies.
An example is shown below:

```toml
[build.myproject-deps]
command = '''
  mkdir -p $out
  npm ci
  cp -r node_modules $out
'''

[build.myproject]
command = '''
  # Copy node modules built in the previous step
  cp --no-preserve=mode -r ${myproject-deps}/node_modules ./
  ...
  # The rest of the build is the same
'''
sandbox = "pure"
```

### Nix expression builds

To build a project using [`buildNpmPackage`](https://nixos.org/manual/nixpkgs/stable/#language-javascript) which will import your existing dependency file:

```nix
{
  buildNpmPackage,
  importNpmLock,
}:

buildNpmPackage (final: {
  pname = "myproject";
  version = "0.1.0";
  src = ../../../.;

  npmDeps = importNpmLock {
    npmRoot = final.src;
  };
  npmConfigHook = importNpmLock.npmConfigHook;
  npmBuildScript = "build";
});
```

[build-concept]: ../../concepts/builds.md
[pure-builds-section]: ../../concepts/manifest-builds.md#pure-builds
