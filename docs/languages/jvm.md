---
title: JVM
description: Common questions and solutions for using the JVM ecosystem with Flox
---

# JVM

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

### Manifest builds

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
[build-concept]: ../concepts/builds.md
