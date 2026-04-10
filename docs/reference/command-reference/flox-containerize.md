---
title: flox containerize
description: Command reference for the `flox containerize` command.
---

# `flox containerize` command

> **Warning:** This command is **experimental** and its behaviour is
> subject to change

## NAME

flox-containerize - export an environment as a container image

## SYNOPSIS

    flox [<general-options>] containerize
         [-d=<path> | -r=<owner/name>]
         [-o=<path>]

## DESCRIPTION

Export a Flox environment as a container image. The image is written to
`<path>`. Then use `docker load -i <path>` to load the image into
docker. When `<path>` is `-`, the image is written to `stdout`, and can
be piped into `docker load` directly.

Running the container will behave like running `flox activate`. Running
the container interactively with `docker run -it <container id>`, will
launch a bash subshell in the container with all your packages and
variables set after running the activation hook. This is akin to
`flox activate`

Running the container non-interactively with `docker run <container id>`
allows you to run a command within the container without launching a
subshell, similar to `flox activate --`

**Note**: The `containerize` command is currently **only available on
Linux**. The produced container however can also run on macOS.

## OPTIONS

`-o`, `--output`  
Write the container to `<path>` (default:
`./<environment-name>-container.tar`) If `<path>` is `-`, writes to
`stdout`.

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

## EXAMPLES

Create a container image file and load it into Docker:

    $ flox containerize -o ./mycontainer.tar
    $ docker load -i ./mycontainer.tar

Pipe the image into Docker directly:

    $ flox containerize -o - | docker load

Run the container interactively:

    $ flox init
    $ flox install hello
    $ flox containerize -o - | docker load
    $ docker run --rm -it <container id>
    [floxenv] $ hello
    Hello, world!

Run a specific command from within the container, but do not launch a
subshell.

    $ flox init
    $ flox install hello
    $ flox containerize -o - | docker load
    $ docker run <container id> hello
    Hello, world

## SEE ALSO

[`flox-activate(1)`](./flox-activate.md) \[`docker-load(1)`\]
