---
title: Go
description: Common questions and solutions for using Go with Flox
---

# Go

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

Since the output of the build must be copied to the `$out` directory, you may either install the output directly to `$out`, or you may copy the executable there manually after running `go build`.

Install directly to `$out`:

```toml
[build.myproject]
command = '''
  GOBIN=$out/bin go install
'''
```

Copy the executable manually:

```toml
[build.myproject]
command = '''
  mkdir -p $out/bin
  go build
  cp ./myproject $out/bin/myproject
'''
```

[build-concept]: ../../concepts/manifest-builds.md
