---
title: Node.js
description: Common questions and solutions for using Node.js with Flox
---

# Node.js

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

Node.js applications should have their `node_modules` directory placed under
the `$out/lib` directory.

```toml
[build.myproject]
command = '''
  npm install --production --prefix=$out/lib
'''
```

[build-concept]: ../../concepts/manifest-builds.md
