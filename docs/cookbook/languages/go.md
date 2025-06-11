---
title: Go
description: Common questions and solutions for using Go with Flox
---

# Go

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

Since the output of the build must be copied to the `$out` directory, you may either install the output directly to `$out`, or you may copy the executable there manually after running `go build`.

Go adds metadata to compiled binaries that allows details from the build environment to leak through.
For example, a compiled binary will contain absolute paths to source files.
This can cause builds to fail as it interferes with Flox's ability to determine when a build depends on an artifact that aren't included in the build's closure, i.e. when a build has missing dependencies.
To address this you'll need to compile your programs with the `-trimpath` option.

Install directly to `$out`:

```toml
[build.myproject]
command = '''
  GOBIN=$out/bin go install -trimpath
'''
```

Copy the executable manually:

```toml
[build.myproject]
command = '''
  mkdir -p $out/bin
  go build -trimpath
  cp ./myproject $out/bin/myproject
'''
```

[build-concept]: ../../concepts/manifest-builds.md
