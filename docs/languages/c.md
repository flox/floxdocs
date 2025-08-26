---
title: C/C++
description: Common questions and solutions for using C with Flox
---

# C/C++

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

### Manifest builds

#### Autotools

Since `autotools` isn't specific to C, this example will also work for any project using `autotools`.
Since the output of the build must be copied to the `$out` directory, you must set the install prefix to `$out`.

```toml
[build.myproject]
command = '''
  ./configure --prefix=$out
  make
  make install
'''
```

#### CMake

Doing a `CMake` build looks much the same as `autotools`.

```toml
[build.myproject]
command = '''
  cmake -DCMAKE_INSTALL_PREFIX=$out
  make
  make install PREFIX=$out
'''
```

### Nix expression builds

To build a project using `clang`:

```nix
{ clangStdenv }:

clangStdenv.mkDerivation {
  pname = "myproject";
  version = "0.0.1";
  src = ../../.;

  installFlags = [ "PREFIX=$(out)" ];
}
```

[build-concept]: ../../explanations/builds.md
