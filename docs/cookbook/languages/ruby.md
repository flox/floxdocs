---
title: Ruby
description: Common questions and solutions for using Ruby with Flox
---

# Ruby

## Build with Flox

Not only can you _develop_ your software with Flox, but you can _build_ it as well.
See the [builds][build-concept] concept page for more details.

Since Ruby is not a compiled language, to create an executable artifact you must create a shell script that calls `bundle exec`. Configure bundler to use the local directory to store the bundles by setting `$GEM_HOME` to something like `./vendor`. If you're Gemfile compiles native extensions, you may also want to `unset CPATH`. See the [Flox ruby environment](https://hub.flox.dev/flox/ruby) for more information, examples and specific details.

For example, say you have an application whose source is in `app.rb`, and that you created a script called `myproject` at the root of your repository with the following contents:

```bash
#!/usr/bin/env bash

bundle exec ruby app.rb
```

The build command for your application would look like this:

```toml
[build.myproject]
command = '''
  # Vendor dependencies
  bundle

  # Create the output directories
  mkdir -p $out/{lib,bin}

  # Copy source files to $out/lib
  cp -pr * $out/lib

  # Move the executable script
  mv $out/lib/myproject $out/bin/myproject
'''
```

[build-concept]: ../../concepts/manifest-builds.md
