---
title: flox services status
description: Command reference for the `flox services status` command.
---

# `flox services status` command

## NAME

flox-services-status - display the status of services

## SYNOPSIS

    flox [<general-options>] services status
         [-d=<path> | -r=<owner/name>]
         [--json]
         [<name>] ...

## DESCRIPTION

Displays the status of one or more services.

If no services are specified, then all services will be displayed. If no
services have been started for this environment, an error will be
displayed. An error will also be displayed if one of the specified
services does not exist.

## OPTIONS

`-d`, `--dir`  
Path containing a .flox/ directory.

`--json`  
Print statuses formatted as JSON. Each service is printed as a single
JSON object on its own line.

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

Display statuses for all services:

    $ flox services status
    NAME       STATUS            PID
    sleeping   Running         89718
    myservice  Running         12345

Display the status of a single service:

    $ flox services status myservice
    NAME       STATUS            PID
    myservice  Running         12345

## SEE ALSO

[`flox-activate(1)`](./flox-activate.md)
[`flox-services-start(1)`](./flox-services-start.md)
