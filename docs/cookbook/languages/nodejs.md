---
title: Node.js
description: Common questions and solutions for using Node.js with Flox
---

# Node.js

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

### npm

Building Node.js packages with `npm` looks similar to building for containers or serverless functions.
On a high level, builds for Node.js-based projects generally follow this pattern:

```.toml
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

[build-concept]: ../../concepts/manifest-builds.md
