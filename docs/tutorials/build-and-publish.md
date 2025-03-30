---
title: Build and publish packages
description: Building and publishing software artifacts with Flox
---

# Building with Flox

At some point during the development process you typically want to build your application so that it can be distributed or run.
Flox aims to be the one tool that you need for the entire software development lifecycle, so let's see how you can not only _develop_ your software with Flox, but _build_ it with Flox as well.

## Prepare a project

Let's start by creating a simple Go project.
We'll create a directory called `myproject` and create a Flox environment inside of it so we can install our tools.

```text
$ mkdir myproject
$ cd myproject
$ flox init
✨ Created environment 'myproject' (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
  $ flox edit                <- Add environment variables and shell hooks
```

Since we're using Go, we'll want to install Go:

```text
$ flox install go
✅ 'go' installed to environment 'myproject'
$ # let's see what version of Go we have
$ flox list
go: go (1.24.1)
```

Now let's add some very minimal code so that we have something to build.
For now this will be a very simple "hello world" application.
Start by activating the environment so that we have our Go application available.

```text
$ flox activate
✅ You are now using the environment 'myproject'.
To stop using this environment, type 'exit'

flox [myproject] $ go mod init hello
go: creating new go.mod: module hello
flox [myproject] $ touch main.go
```

Now edit `main.go` to have the following contents:

```go
package main

import "fmt"

func main() {
  fmt.Println("Hello World")
}
```

Now let's ensure that we can build the `hello` program:

```text
flox [myproject] $ go build
flox [myproject] $ # ensure that 'hello' was built
flox [myproject] $ ls -al
.rw-r--r--   24 zmitchell 27 Mar 14:31 go.mod
.rwxr-xr-x 2.4M zmitchell 27 Mar 14:32 hello
.rw-r--r--   77 zmitchell 27 Mar 14:32 main.go
```

We can build the program, so let's verify that we can run it:

```text
flox [myproject] $ # ensure that 'hello' runs
flox [myproject] $ ./hello
Hello World
```

Everything appears to be in working order, so now we can discuss what it looks like to build the program with Flox instead of running the build commands ourselves.

## Define a build

In order to define a Flox build, we add an entry to the `[build]` section of the manifest.
Every name added to the `build` section creates a new artifact.
In our case the artifact will be the compiled Go program, but you can use Flox to build all kinds of things.
See the [builds][build-concept] page for more examples of what you can build with Flox.

All that's necessary to define a build is a short script that does two things:

- Runs any commands necessary to build the program
- Copies the program to a directory called `$out`

The `$out` shell variable holds the path to a temporary directory where your build artifact should be placed (again, "artifact" in our case means the compiled `hello` program).
The `$out` directory adheres to the [Filesystem Hierarchy Standard (FHS)][fhs], which is just the formal name for the convention of placing executable files in `/bin`, libraries in `/lib`, etc.
For this `hello` program we'll want to place it in `$out/bin` since `hello` is an executable program, and that's where the FHS says to put those types of files.
Flox expects you to put executables there, and if you put them somewhere else you may experience unexpected behavior.

Let's now define our build.
Run `flox edit` so that you can edit your manifest, and add the following section:

```toml
[build.hello]
command = '''
  mkdir -p $out/bin
  go build # produces the ./hello executable file
  cp hello $out/bin/hello
'''
```

## Perform a build

It's the moment of truth, let's run `flox build` to have Flox build our `hello` program for us:

```text
flox [myproject] $ flox build
Rendering hello build script to /var/folders/qn/77rf0syj2s7djp588bzp5vkm0000gn/T//d6f2efa3-hello-build.bash
Building hello-unknown in local mode
00:00:00.004571 + go build
00:00:00.205192 + mkdir -p /tmp/store_d6f2efa321a606aebf3b41d0d96ace1d-hello-unknown/bin
00:00:00.207584 + cp hello /tmp/store_d6f2efa321a606aebf3b41d0d96ace1d-hello-unknown/bin/hello
this derivation will be built:
  /nix/store/g3z03h4p2xa9rf6y78d0xamryggawvha-hello-unknown.drv
building '/nix/store/g3z03h4p2xa9rf6y78d0xamryggawvha-hello-unknown.drv'...
hello-unknown> signing /nix/store/2hc9mjxs6wqcd8cscw9ll650jv1k6wn1-hello-unknown
hello-unknown> patching script interpreter paths in /nix/store/2hc9mjxs6wqcd8cscw9ll650jv1k6wn1-hello-unknown/bin/hello
Completed build of hello-unknown in local mode

✨ Build completed successfully. Output created: ./result-hello
```

It worked!
The last line of output tells us that the built output was created in our current directory and called `result-hello`.
Every build output has the name `result-<name>` where `<name>` is the name you used in the `[build]` section of your manifest (for example `[build.hello]`).

This `result-hello` file is actually a symbolic link to the final destination of the `$out` directory.
That means we can't run `result-hello` directly, and instead we need to run `result-hello/bin/hello`.
Let's do that now:

```text
flox [myproject] $ ./result-hello/bin/hello
Hello World
```

## Define a second build

It's possible to define more than one build for your Flox environment.
Why would you want to do that?
In our case we have a Go program, and by default the Go compiler optimizes for fast builds, but not necessarily fast or small executables.
This makes development nice because you get the fastest possible feedback cycle when developing your software, but in production you probably want a more optimized program.
We can define one build for development, and another build for our "production" `hello` program, both using the same source code and tools!

Run `flox edit` to edit your manifest again, and add this new build:

```toml
[build.hello-opt]
command = '''
  go build -ldflags="-s -w" -gcflags="-l=4"
  mkdir -p $out/bin
  cp hello $out/bin/hello
'''
```

This build produces a version of our `hello` program with some optimizations applied.
Now if you run `flox build` it will run both the `hello` and `hello-opt` builds, or we could specify just the `hello-opt` build with `flox build hello-opt`:

```text
flox [myproject] $ flox build hello-opt
Rendering hello-opt build script to /var/folders/qn/77rf0syj2s7djp588bzp5vkm0000gn/T//60dfcc45-hello-opt-build.bash
Building hello-opt-unknown in local mode
00:00:00.004522 + go build '-ldflags=-s -w' -gcflags=-l=4
00:00:00.155021 + mkdir -p /tmp/store_60dfcc45203ccd97815dbc9aecc6d84d-hello-opt-unknown/bin
00:00:00.157435 + cp hello /tmp/store_60dfcc45203ccd97815dbc9aecc6d84d-hello-opt-unknown/bin/hello
this derivation will be built:
  /nix/store/k6za2nx7jla6rwzs7lj1qm4rc03v9z7q-hello-opt-unknown.drv
building '/nix/store/k6za2nx7jla6rwzs7lj1qm4rc03v9z7q-hello-opt-unknown.drv'...
hello-opt-unknown> signing /nix/store/nbykbq9fy0z67hhlf1kvf8wk7wb29x59-hello-opt-unknown
hello-opt-unknown> patching script interpreter paths in /nix/store/nbykbq9fy0z67hhlf1kvf8wk7wb29x59-hello-opt-unknown/bin/hello
Completed build of hello-opt-unknown in local mode

✨ Build completed successfully. Output created: ./result-hello-opt
```

## Publish the artifact

!!! tip "This is a Flox for Teams feature"

    This is a paid feature included with Flox for Teams.
    Sign up for [early access][early] if you are interested in accessing this feature.

Now that the artifact is built, we can send it somewhere.
In order to use this feature you need to have an organization configured with a Catalog Store.
If you already have an organization configured, see the Catalog Store cookbook page to configure your Catalog Store.

Let's say you've already done that for your organization called `myorg`.
Now that you've built the artifact you can [publish][publish-concept] it to your private catalog via the `flox publish` command.
This command has a few requirements to make sure that the artifact you're publishing can be built by other people reproducibly:

- The Flox environment must be in a git repository.
- All tracked files in the repository must be clean.
- The repository must have a remote configured.
- The current revision must be pushed to the remote.
- The Flox environment must contain at least one package so that the published package can be attached to a point in time in the Base Catalog (where our `go` package came from).

Let's say that we've done all of that so that we can publish our `hello` program:

```text
flox [myproject] $ flox publish hello
```

The `flox publish` command performs a clean build of the artifact in a temporary directory to ensure that the build doesn't depend on anything outside of the git repository.

In order to upload an artifact during the publish process (and not just upload metadata), you must provide a signing key via the `--signing-private-key` option.
Attempting to upload an artifact without a signing key is an error because other users would not be able to install the artifact.

## Install the artifact

!!! tip "This is a Flox for Teams feature"

    This is a paid feature included with Flox for Teams.
    Sign up for [early access][early] if you are interested in accessing this feature.

Now that you've published the artifact, it will show up in [`flox search`][flox-search] and [`flox show`][flox-show], and can be installed via [`flox install`][flox-install].
The package will appear with the name of your organization prefixed to the package name.
In our case the organization is `myorg` and the package name is `hello`, so it will appear as `myorg/hello`.
Let's see that in action with `flox search`:

```text
flox [myproject] $ flox search hello
myorg/hello                 <no description provided>
hello                       Program that produces a familiar, friendly greeting
hello-go                    Simple program printing hello world in Go
hello-cpp                   Basic sanity check that C++ and cmake infrastructure are working
nwg-hello                   GTK3-based greeter for the greetd daemon, written in python
hello-unfree                Example package with unfree license (for testing)
hello-wayland               Hello world Wayland client
sbclPackages.hello-clog     <no description provided>
texlivePackages.othello     Modification of a Go package to create othello boards
sbclPackages.hello-builder  <no description provided>

Showing 10 of 23 results. Use `flox search hello --all` to see the full list.

Use 'flox show <package>' to see available versions
```

You can see that our `myorg/hello` package is the first result.
Now that we know it's available, let's install it:

```text
flox [myproject] $ flox install myorg/hello
✅ 'myorg/hello' installed to environment 'myproject'
```

## Conclusion

With Flox you have an integrated experience where the same tool you use to develop software is also used to build it, publish it, and eventually consume it.
The story doesn't end here though.
In this guide we've shown you how to build and distribute programs, but you can also use it to distribute configuration files (or any other file).
See the [builds][extra-builds] concept page for examples of what else you can build and publish with Flox.

[build-concept]: ../concepts/manifest-builds.md
[fhs]: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
[flox-install]: ../reference/command-reference/flox-install.md
[flox-show]: ../reference/command-reference/flox-show.md
[flox-search]: ../reference/command-reference/flox-search.md
[extra-builds]: ../concepts/manifest-builds.md#example-configuration-files
