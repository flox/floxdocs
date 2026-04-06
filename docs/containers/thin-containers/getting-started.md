---
title: "Getting started with Thin Containers"
description: "Run your first Flox environment in a Docker container in under a minute."
---

# Getting started with Thin Containers

This guide walks you through running Flox environments in Docker containers, from your first command to using sandbox mode with your own projects.

## Prerequisites

- [Docker Desktop][docker-install] (macOS/Windows) or Docker Engine (Linux), or [Podman][podman-install]
- For sandbox mode (steps 5--6): the [Flox CLI][flox-install]

## 1. Run your first thin container

Run a command from a FloxHub environment:

```{ .bash .copy }
docker run --rm -v flox-store:/nix \
  flox/run flox/redis -- redis-server --version
```

Here's what happens:

1. Docker pulls the lightweight `flox/run` image (if not already cached)
2. The Nix store volume (`flox-store`) is created and mounted at `/nix`
3. Flox resolves the `flox/redis` environment from FloxHub and installs the packages
4. The `redis-server --version` command runs inside the activated environment

!!! note
    The first run takes 30--60 seconds as it populates the Nix store with packages.
    This is a one-time cost --- subsequent runs reuse the cached store.

## 2. See the caching in action

Run another command from the same environment:

```{ .bash .copy }
docker run --rm -v flox-store:/nix \
  flox/run flox/redis -- redis-cli --version
```

This time it completes in ~5 seconds.
The packages are already in the `flox-store` volume, so there's nothing to download or build.

## 3. Explore interactively

Drop into an interactive shell inside the environment:

```{ .bash .copy }
docker run --rm -it -v flox-store:/nix \
  flox/run flox/redis
```

Inside the container, only the packages declared in the environment are available:

```{ .console .no-copy }
# These work --- they're in the Flox environment
$ redis-server --version
Redis server v=7.x.x ...

$ redis-cli --version
redis-cli 7.x.x

# These don't --- isolation from the host
$ which vim
$                    # not found
$ which curl
$                    # not found
```

Type `exit` to leave the container.

## 4. Try a different environment

Run a Python environment to see that common packages are shared:

```{ .bash .copy }
docker run --rm -v flox-store:/nix \
  flox/run flox/python-pip -- python3 --version
```

Because the Nix store is content-addressed, packages shared between `flox/redis` and `flox/python-pip` (like `glibc`) are stored only once in the `flox-store` volume.

## 5. Use sandbox mode

If you have the Flox CLI installed, the `--sandbox` flag handles all the Docker details for you:

```{ .bash .copy }
flox activate --sandbox -r flox/redis
```

Inside the sandbox you get the same isolated environment, but you didn't need to remember any Docker flags.

Run a command directly:

```{ .bash .copy }
flox activate --sandbox -r flox/redis -- redis-server --version
```

### Custom image registry

If you're behind a firewall that blocks Docker Hub, use the `--container-image` flag to specify an alternative registry:

```{ .bash .copy }
flox activate --sandbox \
  --container-image myregistry.example.com/flox/empty:latest \
  -r flox/redis
```

## 6. Sandbox with your project

Sandbox mode mounts your current working directory into the container at `/work`.
Your code runs in isolation, but file changes persist on the host.

Create a test script:

```{ .bash .copy }
mkdir -p /tmp/sandbox-demo && cd /tmp/sandbox-demo
cat > hello.py << 'EOF'
import sys
print(f"Hello from sandbox! Python {sys.version}")
EOF
```

Run it in a sandbox:

```{ .bash .copy }
flox activate --sandbox -r flox/python-pip -- python3 hello.py
```

```{ .console .no-copy }
Hello from sandbox! Python 3.12.x
```

The script ran inside the container, but `hello.py` is still on the host after the container exits.

## 7. Cleanup

Remove the cached Nix store volume when you no longer need it:

```{ .bash .copy }
docker volume rm flox-store
```

Remove the demo files:

```{ .bash .copy }
rm -rf /tmp/sandbox-demo
```

## Next steps

- Read about [how thin containers work](../tech.md) under the hood
- Learn about [Imageless Kubernetes](../imageless-kubernetes/intro.md) for running the same model in production
- Explore [FloxHub][floxhub] to find environments to try

[docker-install]: https://docs.docker.com/get-docker/
[podman-install]: https://podman.io/docs/installation
[flox-install]: ../../install-flox/install.md
[floxhub]: ../../concepts/floxhub.md
