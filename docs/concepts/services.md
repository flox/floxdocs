---
title: Services
description: Using services with your environment
---

# Services

It is very common for software projects to depend on other programs for core
parts of their functionality.
A web service may depend on a load balancer and a database.
A developer working on the front end of a website may need a development server
running that hot-reloads the site as they tweak the CSS.
You may also want a program that automatically runs your test suite when file
changes are detected.

What these use cases all have in common is that they use long-running programs
as part of the development lifecycle,
and the developer likely wants those programs running as soon as they sit down
to start working on the project.

We call these long-running programs "services",
and you can integrate them directly with your environment.

## Defining services

Services are defined in the `[services]` section of the manifest.
Services have a very simple schema consisting of a `command` to run to start
the service,
any `vars` you want set specifically for the service,
and whether the service spawns a background process.
See [`manifest-toml(1)`](../reference/command-reference/manifest.toml.md) for
more details on the exact format of the `[services]` section of the manfiest.

An example service definition is shown below:
```toml
[services.database]
command = "postgres start"
vars.PGUSER = "myuser"
vars.PGPASSWORD = "super-secret"
vars.PGDATABASE = "mydb"
vars.PGPORT = "9001"
```

This definition creates a service called `database` that starts a PostgreSQL
database and configures some of its properties through environment variables.

Some services cannot be shut down by the default mechanism
(sending the spawned process a `SIGTERM`).
Most often this is because the spawned process itself spawns another process
(typically a daemon) and then terminates.
In this case you need to provide your own command for shutting down the
service.
You do this by setting `is-daemon = true` for the service and providing a
`shutdown.command`.
Together these fields allow the service manager to shut down services that
background themselves,
though any service may provide a `shutdown.command` and it will be used
instead of sending a `SIGTERM`.

## Starting services

Services can be started automatically when you activate your environment via
the `flox activate --start-services` command
(or via the shorter `flox activate -s`).
This will start services as part of activating your environment.
When activating your environment from multiple shells you only need to start
the services once.
Since your services are just processes running on your machine,
they will be visible to any other activations.

Activating your environment without the `--start-services` flag will not start
the services.
If you activate your environment without services and then later decide that
you want to start them, that is done via the `flox services start` command.
When called without any arguments this command will start all services listed
in the manifest.
You can also specify individual service names,
in which case only those services will be started.
If you accidentally provide a service name that doesn't exist,
you'll get an error and no services will be started.
If a service is already running,
you'll see a warning but the command will otherwise succeed.

## Stopping services

Services are **automatically stopped** when the last running activation of the
environment terminates.
This means that if you `flox activate -s` in a single shell,
the services will be shut down automatically when you exit that shell.
Similarly, if you `flox activate -s` in one shell, then `flox activate` in two
more shells,
the services won't be shut down until all three of those activations have
terminated.

You can stop services yourself via the `flox services stop` command.
You can also specify individual service names,
in which case only those services will be stopped.
If you accidentally provide a service name that doesn't exist,
you'll get an error and no services will be stopped.
If a service is already stopped,
you'll see a warning but the command will otherwise succeed.

## Restarting services

Services can be restarted via the `flox services restart` command.
You can also specify individual service names,
in which case only those services will be restarted.
If you accidentally provide a service name that doesn't exist,
you'll get an error and no services will be restarted.

## Handling environment edits

While working in your environment that has running services,
you may discover that you need to edit a service definition or some other part
of the environment.
In this scenario you would call `flox edit` like usual,
but now the manifest is out of sync with both the current activation of your
environment _and_ the running services.
After making the edit you'll see a warning about needing to reactivate your
environment in order to apply the changes to your shell,
but if you just want to apply the changes to your services
(say you only modified a service definition)
you can do so without needing to reactivate your environment.

There are two ways to accomplish this:

1. `flox services restart`
2. `flox services stop` followed by `flox services start`

In both cases the services will be started in an ephemeral activation so that
the services can be started in the same environment as they otherwise would be
in a new activation.
The `flox services stop` in the second case is only necessary if any services
are currently running.

## Checking on services

You can see the status of your services with the `flox services status`
command.
This will display the name of the service, the PID, and its status.
An example is shown below:

```
NAME       STATUS            PID
database   Running         12345
server     Running         23456
```

You can see the logs of your services with the `flox services logs` command.
This command operates in two modes:

- all services with `--follow`
- single service with either `--follow` or `--tail`

When no services are specified the `--follow` flag must be provided,
in which case logs for all running services will be displayed in real time.
If a single service name is provided then the logs for that service will be
displayed.

Logs for the service manager itself are stored as `services.*.log` files in the
`.flox/logs` directory of your environment.
