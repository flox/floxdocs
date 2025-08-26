---
title: flox services logs
description: Command reference for the `flox services logs` command.
---

# `flox services logs` command

## NAME

flox-services-logs - show logs of services

## SYNOPSIS

    flox [<general-options>] services logs
         [-d=<path> | -r=<owner/name>]
         [--follow]
         [-n=<num>]
         [<name>] ...

## DESCRIPTION

Display the logs of the specified services.

If no services are specified, then the `--follow` flag is required and
logs from all services will be printed in real time.

One or more service names specified with the `--follow` flag will follow
the logs for the specified services.

If a service name is supplied without the `--follow` flag then all of
the available logs are displayed for that service. If specified with the
`-n` flag then only the most recent `<num>` lines from that service are
displayed.

An error will be returned if a specified service does not exist.

## OPTIONS

`-d`, `--dir`  
Path containing a .flox/ directory.

`--follow`  
Follow log output for the specified services. Required when no service
names are supplied.

`-n`, `--tail`  
Display only the last `<num>` lines from the logs of the specified
services.

`<name>`  
Which service(s) to display logs for. When omitted logs from all
services will be displayed but the `--follow` flag is required.

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

Follow logs for all services:

    $ flox services logs --follow
    service1: hello
    service2: hello
    ...

Follow logs for a subset of services:

    $ flox services logs --follow service1 service3
    service1: hello
    service3: hello
    ...

Display all available logs for a single service:

    $ flox services logs myservice
    starting...
    running...
    stopping...
    completed

## SEE ALSO

[`flox-activate(1)`](./flox-activate.md)
[`flox-services-start(1)`](./flox-services-start.md)
