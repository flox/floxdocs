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

### Vendoring dependencies in pure builds

As discussed in the [pure builds][pure-builds-section] of the Builds concept page, pure builds run in a sandbox without network access on Linux.
A pure build can be run as a multi-stage build where the first step vendors dependencies.
An example is shown below:

```toml
[build.myproject-deps]
command = """
   # Don't use or update paths in the real project config.
   export BUNDLE_IGNORE_CONFIG=true

   # Pre-fetch the deps outside of the sandbox.
   export BUNDLE_PATH=$out
   export BUNDLE_CACHE_PATH=${out}/cache
   bundle cache --no-install

   # These gems appear to be duplicated irrespective of `--no-install`
   rm -rf $out/ruby
"""

[build.myproject]
command = """
   mkdir -p $out/{lib,bin}

   # Don't use or update paths in the real project config.
   export BUNDLE_IGNORE_CONFIG=true

   # Perform an isolated install using pre-fetched deps.
   export BUNDLE_PATH=$out/lib/vendor
   export BUNDLE_CACHE_PATH=${myproject-deps}/cache
   export BUNDLE_DEPLOYMENT=true
   bundle install --standalone --local

   cp Gemfile Gemfile.lock $out/lib
   cp app.rb quotes.json $out/lib
   cp quotes $out/bin/myproject
"""
sandbox = "pure"
```

[build-concept]: ../../concepts/builds.md
[pure-builds-section]: ../../concepts/manifest-builds.md#pure-builds
