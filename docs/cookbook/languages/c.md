---
title: C
description: Common questions and solutions for using C with Flox
---

# C

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

This example will assume you're using `autotools`.
Since `autotools` isn't specific to the C language, this example will also work for any project using `autotools`.
Since the output of the build must be copied to the `$out` directory, you must set the install prefix to `$out`.

```toml
[build.myproject]
command = '''
  ./configure --prefix=$out
  make
  make install
'''
```

[build-concept]: ../../concepts/manifest-builds.md
