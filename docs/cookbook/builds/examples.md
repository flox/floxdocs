---
title: Build examples
description: Examples of builds for various languages and frameworks
---

Building your software with Flox is as simple as providing a short script
to run the build command and copy the artifact to a Flox-provided directory.
Below are examples for various ecosystems.

## Autotools

```bash
[build.myproject]
command = '''
  ./configure --prefix=$out
  make
  make install
'''
```

## Go

```
[build.myproject]
command = '''
  GOBIN=$out/bin go install
'''
```

## Rust

```bash
[build.myproject]
command = '''
  cargo build --release
  mkdir -p $out/bin
  cp target/release/myproject $out/bin/myproject
'''
```

## Python

For Python projects a build looks like installing the project to the `$out`
directory.

```bash
[build.myproject]
command = '''
  pip install --target=$out .
'''
```

Note the trailing `.` to indicate that you're installing the package in the
current directory.
If you're working in a repository with multiple packages in subdirectories,
you would replace `.` with the path to the package sources.

This works for projects using `pyproject.toml` as well (including Poetry) as
long as the `[build-system]` section of `pyproject.toml` is filled out.

## Node.js

Node.js applications should have their `node_modules` directory placed under
the `$out/lib` directory.

```bash
[build.myproject]
command = '''
  npm install --production --prefix=$out/lib
'''
```
