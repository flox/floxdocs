---
title: flox services stop
description: Command reference for the `flox services stop` command.
---

# `flox services stop` command

## NAME

flox-services-stop - stop running services

## SYNOPSIS

    flox [<general-options>] services stop
         [-d=<path> | -r=<owner/name>]
         [<name>] ...

## DESCRIPTION

Stops the specified running services.

If no services are specified, then all services will be stopped. If any
of the specified services are not currently running, a warning will be
displayed and the remaining services will be stopped.

If any of the specified services do not exist, an error will be returned
and no services will be stopped. If an error is encountered while
stopping one of the specified services, the remaining services will
still be stopped a warning will be displayed for the services that
failed to stop, and a non-zero exit code will be returned.

## OPTIONS

`-d`, `--dir`  
Path containing a .flox/ directory.

`<name>`  
The name(s) of the services to stop.

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

Stop a running service named ‘server’:

    $ flox services stop server

Stop all running services:

    $ flox services stop

Attempt to stop a service that doesn’t exist:

    $ flox services stop myservice doesnt_exist
    ❌ ERROR: Service 'doesnt_exist' not found.  

Attempt to stop a service that isn’t running:

    $ flox services stop running not_running
    ⚠️  Service 'not_running' is not running
    ✅ Service 'running' stopped  

## SEE ALSO

[`flox-activate(1)`](./flox-activate.md)
