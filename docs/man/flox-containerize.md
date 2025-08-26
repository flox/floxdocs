---
title: flox containerize
description: Command reference for the `flox containerize` command.
---

# `flox containerize` command

## NAME

flox-containerize - export an environment as a container image

## SYNOPSIS

    flox [<general-options>] containerize
         [-d=<path> | -r=<owner/name>]
         [-f=<file>] [--runtime=<runtime>]
         [--tag=<tag>]

## DESCRIPTION

Export a Flox environment as a container image. The image can be written
to a container runtime registry, a file, or another process.

**Note**: Exporting a container from macOS requires a supported runtime
because a proxy container is used to build the environment and image.
You may be prompted for permissions to share files into the proxy
container. Files used in the proxy container are cached using a `docker`
or `podman` volume named `flox-nix`. It can safely be removed any time a
`flox containerize` command is not running using either
`docker volume rm flox-nix` or `podman volume rm flox-nix`.

Running the container will behave like running `flox activate`. Running
the container interactively with `docker run -it <container id>`, will
launch a bash subshell in the container with all your packages and
variables set after running the activation hook. This is akin to
`flox activate`.

Running the container non-interactively with `docker run <container id>`
allows you to run a command within the container without launching a
subshell, similar to `flox activate --`.

## OPTIONS

`-f`, `--file`  
File to write the container image to. `-` to write to stdout. Defaults
to `{name}-container.tar` if `--runtime` isn’t specified or detected.

`--runtime`  
Container runtime to store the image (when `--file` is not specified) or
build the image (when on macOS). Defaults to detecting the first
available on PATH.

### Environment Options

If no environment is specified for an environment command, the
environment in the current directory or the active environment that was
last activated is used.

`-d`, `--dir`  
Path containing a .flox/ directory.

`-r`, `--remote`  
A remote environment on FloxHub, specified in the form `<owner>/<name>`.

### General Options

`-h`, `--help`  
Prints help information.

The following options can be passed when running any `flox` subcommand
but must be specified *before* the subcommand.

`-v`, `--verbose`  
Increase logging verbosity. Invoke multiple times for increasing detail.

`-q`, `--quiet`  
Silence logs except for errors.

## MANIFEST CONFIGURATION

Configuration for the container image produced by `flox containerize`
may be specified in a `[containerize.config]` table in the environment
manifest.

> **Warning:** `containerize.config` is **experimental**, and its
> behaviour is subject to change

The following options from the OCI spec are supported, specified in
`kebab-case` rather than `PascalCase`:

    ContainerizeConfig ::= {
      user                      = null | <STRING>
    , exposed-ports             = null | [<STRING>, ...]
    , cmd                       = null | [<STRING>, ...]
    , volumes                   = null | [<STRING>, ...]
    , working-dir               = null | <STRING>
    , labels                    = null | Map[STRING, STRING]
    , stop-signal               = null | <STRING>
    }

`user`  
The username or UID which is a platform-specific structure that allows
specific control over which user the process run as. This acts as a
default value to use when the value is not specified when creating a
container. For Linux based systems, all of the following are valid:
`user`, `uid`, `user:group`, `uid:gid`, `uid:group`, `user:gid`. If
`group`/`gid` is not specified, the default group and supplementary
groups of the given `user`/`uid` in `/etc/passwd` and `/etc/group` from
the container are applied. If `group`/`gid` is specified, supplementary
groups from the container are ignored. This will add an entry to
/etc/passwd and /etc/groups inside the container, so no manual useradd
is required.

`exposed-ports`  
A set of ports to expose from a container running this image. Its values
can be in the format of: `port/tcp`, `port/udp`, `port` with the default
protocol being `tcp` if not specified. These values act as defaults and
are merged with any specified when creating a container.

`cmd`  
Default arguments to the entrypoint of the container. These values act
as defaults and may be replaced by any specified when creating a
container. Flox sets an entrypoint to activate the containerized
environment, and `cmd` is then run inside the activation, similar to
`flox activate -- cmd`.

`volumes`  
A set of directories describing where the process is likely to write
data specific to a container instance.

`working-dir`  
Sets the current working directory of the entrypoint process in the
container. This value acts as a default and may be replaced by a working
directory specified when creating a container.

`labels`  
This field contains arbitrary metadata for the container. This property
MUST use the [annotation
rules](https://github.com/opencontainers/image-spec/blob/main/annotations.md#rules).

`stop-signal`  
This field contains arbitrary metadata for the container. This property
MUST use the [annotation
rules](https://github.com/opencontainers/image-spec/blob/main/annotations.md#rules).

## EXAMPLES

Create a container image file and load it into Docker:

    $ flox containerize -f ./mycontainer.tar
    $ docker load -i ./mycontainer.tar

Load the image into Docker:

    $ flox containerize --runtime docker

    # or through stdout e.g. if `docker` is not in `PATH`:

    $ flox containerize -f - | /path/to/docker

Run the container interactively:

    $ flox init
    $ flox install hello
    $ flox containerize -f - | docker load
    $ docker run --rm -it <container id>
    [floxenv] $ hello
    Hello, world!

Run a specific command from within the container, but do not launch a
subshell.

    $ flox init
    $ flox install hello
    $ flox containerize -f - | docker load
    $ docker run <container id> hello
    Hello, world

Create a container with a specific tag:

    $ flox init
    $ flox install hello
    $ flox containerize --tag 'v1' -f - | docker load
    $ docker run --rm -it <container name>:v1
    [floxenv] $ hello
    Hello, world!

## SEE ALSO

[`flox-activate(1)`](./flox-activate.md) \[`docker-load(1)`\]
