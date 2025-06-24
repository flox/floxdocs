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

### Go compiler adds metadata

Go adds metadata to compiled binaries that allows details from the build environment to leak through.
For example, a compiled binary will contain absolute paths to source files.
This can cause builds to fail as it interferes with Flox's ability to determine when a build depends on an artifact that aren't included in the build's closure, i.e. when a build has missing dependencies.
To address this you'll need to compile your programs with the `-trimpath` option.

### Go builds depend on iana, mailcap, tzdata

The Go `net/http` package has a few runtime dependencies that you may not know you depend on:

- `iana-etc`: used to resolve a protocol or service by name.
- `mailcap`: used to resolve MIME types.
- `tzdata`: used to resolve timezones.

You'll need to add those packages to your environment and add them to the `runtime-packages` of your build if you're limiting which packages are present at runtime:

```toml
runtime-packages = [
  "iana-etc",
  "mailcap",
  "tzdata",
]
```

### Vendoring dependencies in pure builds

As discussed in the [pure builds][pure-builds-section] of the Builds concept page, pure builds run in a sandbox without network access on Linux.
A pure build can be run as a multi-stage build where the first step vendors dependencies.
An example is shown below:

```toml
[build.myproject-deps]
command = '''
  export GOMODCACHE=$out
  go mod download -modcacherw
'''

[build.myproject]
command = """
  export GOMODCACHE=${myproject-deps}
  mkdir -p "$out/bin"
  go build -trimpath -o $out/bin/myproject
  chmod +x $out/bin/myproject
"""
sandbox = "pure"
```

[build-concept]: ../../concepts/manifest-builds.md
[pure-build-section]: ../../concepts/manifest-builds.md#pure-builds
