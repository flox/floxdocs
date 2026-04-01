---
title: Flox and systemd
description: Run Flox environment services as persistent systemd units.
---

# Flox and systemd

Flox environments have a built-in concept of [services][services_concept].
Flox environment services are managed by invoking the `flox services`
category of sub-commands such as [`flox services status`][flox_services_status].
In some scenarios, you may want to register Flox services to be run and managed
by the operating system's systemd.
For example, systemd can auto-start services when the host is booting
or when a service crashes.

This tutorial shows how to create and use systemd services with Flox
by creating unit files manually.
You will learn how to run a Flox environment service as both a
**systemd user unit** and a **systemd system unit**.

## Prerequisites

- A Linux system with systemd support.
  This tutorial was tested on Ubuntu 24.04.
- Flox installed in multi-user mode.
  This tutorial was tested on Flox 1.10.0.

## Constraints

- The systemd service that invokes Flox cannot run as root.
- The service cannot listen on a port with a value less than 1024.
- The UID for the user running the systemd service should be >= 1000
  for logs to function properly.
  See [flox#2e789b5][uid_fix] for details.
- Logs may not function properly if the process forks.
  See [flox#9b1e750][fork_fix] for details.

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
redis-cli -p $REDISPORT ping
# should respond PONG
```

Once verified, stop the services and exit the environment:

``` { .bash .copy }
flox services stop
exit
```

### Create the systemd user service

Create the systemd user unit file:

``` { .bash .copy }
mkdir -p ~/.config/systemd/user/
cat > ~/.config/systemd/user/redis.service << 'EOF'
[Unit]
Description=Redis Server (Flox)

[Service]
ExecStart=flox activate -d /home/ubuntu/redis -c 'redis-server "$REDISCONFIG" --daemonize no --dir "$REDISDATA"'

[Install]
WantedBy=default.target
EOF
```

!!! note "Note"
    Update the path `/home/ubuntu/redis` in the `ExecStart` line to match
    the location where you created the environment.

By default, systemd user units only run while the user is logged in.
Enabling **lingering** allows the service to start at boot without a login session.
If you only need the service to run while you are logged in,
you can skip this step.

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
flox activate -d /home/ubuntu/redis -c 'redis-cli -p "$REDISPORT" ping'
# should respond PONG
```

### User unit cleanup

To stop and fully remove the systemd user unit:

``` { .bash .copy }
systemctl --user stop redis.service
systemctl --user disable redis.service
rm ~/.config/systemd/user/redis.service
systemctl --user daemon-reload
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
sudo chown -R redis:redis /home/redis
sudo -u redis flox pull flox/redis -d /home/redis/redis
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
ExecStart=flox activate -d /home/redis/redis -c 'redis-server "$REDISCONFIG" --daemonize no --dir "$REDISDATA"'

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
flox activate -d /home/ubuntu/redis -c 'redis-cli -p "$REDISPORT" ping'
# should respond PONG
```

!!! note "Note"
    Key differences from the user unit approach:
    the system unit goes in `/etc/systemd/system/`,
    uses `multi-user.target`,
    requires `sudo`,
    and no lingering is needed.

### System unit cleanup

To stop and fully remove the systemd system unit:

``` { .bash .copy }
sudo systemctl stop redis.service
sudo systemctl disable redis.service
sudo rm /etc/systemd/system/redis.service
sudo systemctl daemon-reload
```

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Learn more about services][services_concept]

- :simple-readme:{ .flox-purple .flox-heart } [Sharing environments][sharing_guide]

[services_concept]: ../concepts/services.md
[flox_services_status]: ../man/flox-services-status.md
[sharing_guide]: ./sharing-environments.md
[uid_fix]: https://github.com/flox/flox/commit/2e789b55de153b80a23367b236334ffbe84d6289
[fork_fix]: https://github.com/flox/flox/commit/9b1e7504fd5dd482d9afeda1e21ecfe8d1f86593
