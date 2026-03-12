---
title: Flox and systemd
description: Run Flox environment services as persistent systemd units.
---

# Flox and systemd

Flox environments have a built-in concept of [services][services_concept].
Flox environment services are managed by invoking the `flox services`
category of sub-commands such as [`flox services status`][flox_services_status].

This tutorial shows how to create and use systemd services with Flox
by creating unit files manually.
You will learn how to run a Flox environment service as both a
**systemd user unit** and a **systemd system unit**.

## Prerequisites

- A Linux system with systemd support.
  This tutorial was tested on Ubuntu 24.04.
- Flox installed in multi-user mode.
  This tutorial was tested on Flox 1.10.0.

## Run a Flox environment service as a systemd user unit

In this section you will set up a Redis service from a FloxHub environment
and run it as a systemd user unit.

### Create the Redis environment locally

Create a directory for the environment and pull the `flox/redis` environment
from FloxHub:

``` { .bash .copy }
mkdir -p redis
cd redis
```

``` { .bash .copy }
flox pull flox/redis
```

### Test the environment with Flox services

Before creating the systemd unit,
verify that the environment works with Flox services commands:

``` { .bash .copy }
flox activate
```

``` { .bash .copy }
flox services status
flox services start
```

``` { .bash .copy }
redis-cli ping
# should respond PONG
```

Once verified, stop the services and exit the environment:

``` { .bash .copy }
flox services stop
exit
```

### Create the systemd user service

!!! note "Note"
    The linger configuration is only required if you want the service to start
    on boot without a login.
    Otherwise the user must be logged in before the systemd service attempts
    to start.

Create the systemd user unit file:

``` { .bash .copy }
cat > ~/.config/systemd/user/redis.service << 'EOF'
[Unit]
Description=Redis Server (Flox)

[Service]
ExecStart=flox activate -d /home/ubuntu/redis -- bash -c 'redis-server "$REDISCONFIG" --daemonize no --dir "$REDISDATA"'

[Install]
WantedBy=default.target
EOF
```

!!! note "Note"
    Update the path `/home/ubuntu/redis` in the `ExecStart` line to match
    the location where you created the environment.

Enable lingering so the service starts at boot without login:

``` { .bash .copy }
sudo loginctl enable-linger ubuntu
```

Load, enable, and start the service:

``` { .bash .copy }
systemctl --user daemon-reload
systemctl --user enable redis.service
systemctl --user start redis.service
```

Verify the service is running:

``` { .bash .copy }
systemctl --user status redis.service
```

Verify Redis is responding:

``` { .bash .copy }
flox activate -d /home/ubuntu/redis -- redis-cli -p 16379 ping
# should respond PONG
```

## Run a Flox environment service as a systemd system unit

For services that should run under a dedicated system user rather than
your personal account,
you can create a system-level systemd unit instead.

### Create a dedicated Redis user

``` { .bash .copy }
sudo useradd --system --no-create-home --shell /usr/sbin/nologin redis
```

### Create the environment and set ownership

``` { .bash .copy }
sudo mkdir -p /home/redis
sudo flox pull flox/redis -d /home/redis/redis
sudo chown -R redis:redis /home/redis
```

### Create the system unit file

Since the `redis` user has no login session,
user units will not work.
Create a system unit instead:

``` { .bash .copy }
sudo tee /etc/systemd/system/redis.service << 'EOF'
[Unit]
Description=Redis Server (Flox)

[Service]
User=redis
ExecStart=flox activate -d /home/redis/redis -- bash -c 'redis-server "$REDISCONFIG" --daemonize no --dir "$REDISDATA"'

[Install]
WantedBy=multi-user.target
EOF
```

!!! note "Note"
    Enable lingering is not needed for system units.
    System units start at boot automatically.

### Load, enable, and start

``` { .bash .copy }
sudo systemctl daemon-reload
sudo systemctl enable redis.service
sudo systemctl start redis.service
```

### Verify

``` { .bash .copy }
sudo systemctl status redis.service
```

``` { .bash .copy }
sudo flox activate -d /home/redis/redis -- redis-cli -p 16379 ping
# should respond PONG
```

!!! note "Note"
    Key differences from the user unit approach:
    the system unit goes in `/etc/systemd/system/`,
    uses `multi-user.target`,
    requires `sudo`,
    and no lingering is needed.

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Learn more about services][services_concept]

- :simple-readme:{ .flox-purple .flox-heart } [Sharing environments][sharing_guide]

[services_concept]: ../concepts/services.md
[flox_services_status]: ../man/flox-services-status.md
[sharing_guide]: ./sharing-environments.md
