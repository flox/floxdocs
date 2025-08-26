---
title: flox services start
description: Command reference for the `flox services start` command.
---

# `flox services start` command

## NAME

flox-services-start - start services

## SYNOPSIS

    flox [<general-options>] services start
         [-d=<path> | -r=<owner/name>]
         [<name>] ...

## DESCRIPTION

Starts the specified services.

If any services are currently running, a warning will be displayed for
each specified service that is already running, but the command will
still succeed. If a specified service does not exist, an error will be
displayed and no services will be started.

If no services are currently running, then the services will be started
from an ephemeral activation in order to use the most recent build of
the environment. This may be different from the build of the environment
that the current shell has activated, so the services and your shell may
have different environment variables or values. To ensure that your
shell and the services have the same environment, reactivate your
environment after making edits to the manifest.

A remote environment can only have a single set of running services,
regardless of how many times the environment is activated concurrently.

## OPTIONS

`-d`, `--dir`  
Path containing a .flox/ directory.

`<name>`  
The name(s) of the services to start.

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

## EXAMPLES:

Start a service named ‘server’:

    $ flox services start server

Start all services:

    $ flox services start

Attempt to start a service that doesn’t exist:

    $ flox services start myservice doesnt_exist
    ❌ ERROR: Service 'doesnt_exist' not found.  

Attempt to start a service that is already running:

    $ flox services start running not_running
    ✅ Service 'not_running' started  
    ⚠️  Service 'running' is already running

## SEE ALSO

[`flox-activate(1)`](./flox-activate.md)
[`flox-services-stop(1)`](./flox-services-stop.md)
