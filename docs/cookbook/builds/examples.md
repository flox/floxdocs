---
title: Build examples
description: Examples of builds for various languages and frameworks
---

Building your software with Flox is as simple as providing a short script
to run the build command and copy the artifact to a Flox-provided directory.
Below are examples for various ecosystems.

## Autotools

Since the output of the build must be copied to the `$out` directory, you must set the install prefix to `$out`.

```toml
[build.myproject]
command = '''
  ./configure --prefix=$out
  make
  make install
'''
```

## Go

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

## Rust

Since the output of the build must be copied to the `$out` directory, you'll need to copy the compiled executable out of the `target` directory and into `$out`.
There is an unstable environment variable in Cargo that will allow you to set the output directory of the build, but we'll stick to stable features here:

```toml
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

```toml
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

```toml
[build.myproject]
command = '''
  npm install --production --prefix=$out/lib
'''
```

## JVM

This example will use [Gradle][gradle] and the [shadowJar][shadow] plugin, though a number of build systems exist in the Java ecosystem.
The core of building a Java artifact with Flox looks like this:

- Bundle the application into a JAR
- Place the JAR into `$out/lib/`
- Create a script that calls `java -jar <path to jar>`, where `<path to jar>` is the path to the jar in `$out/lib` at runtime, where `$out` is not set.

```toml
[build.myproject]
  # Create the destination directories
  mkdir -p "$out"/{lib,bin}
  # Build a fat jar with gradle using the shadowJar plugin
  gradle shadowJar
  # Copy the newly built jars to $out
  cp build/libs/*.jar $out/lib

  # Build a script that gets the absolute path to the JAR at run time
  # and then calls 'java -jar $JAR_PATH'
  echo '#!/usr/bin/env bash' > $out/bin/myproject
  echo 'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"' >> $out/bin/myproject
  echo 'JAR_PATH="$SCRIPT_DIR/../lib/myproject-app-all.jar"' >> $out/bin/myproject
  echo 'exec java -jar "$JAR_PATH" "$@"' >> $out/bin/myproject

  # Ensure that the script has the correct permissions
  chmod 755 $out/bin/myproject
```

Since `$out` is not set at runtime, the script that calls `java -jar <path to jar>` needs to find the location of the JAR at runtime.
Note that `pwd` will return the location from which the built artifact is run, not the location of the artifact itself, which is why the script goes through the process of setting `SCRIPT_DIR` and `JAR_PATH`.

[gradle]: https://gradle.org/
[shadow]: https://gradleup.com/shadow/
