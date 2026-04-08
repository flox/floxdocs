---
title: "Thin Containers"
description: "Run Flox environments in Docker or Podman containers without building images."
---

# Thin Containers

Thin containers are a lightweight way to run Flox environments inside Docker or Podman containers.
Unlike traditional containers where all dependencies are baked into an image, thin containers resolve packages **at startup** from a shared Nix store volume.
This means:

- **No image rebuilds** when your environment changes
- **Shared caching** across environments --- common packages are stored once
- **Fast startup** after the first run (~5 seconds vs. 30--60 seconds)
- **True isolation** from the host system --- only packages declared in the environment are available

## Two ways to use thin containers

### 1. Direct Docker or Podman commands

Run any FloxHub environment with a single `docker run` command:

```{ .bash .copy }
docker run --rm -v flox-store:/nix flox/thin flox/redis -- redis-server --version
```

This is useful when you don't have Flox installed on the host, or when integrating with existing Docker-based workflows.

### 2. Sandbox mode (`flox activate --sandbox`)

If you have the Flox CLI installed, the `--sandbox` flag wraps the Docker machinery behind a familiar interface:

```{ .bash .copy }
flox activate --sandbox -r flox/redis
```

Sandbox mode automatically handles volume mounts, TTY detection, and argument forwarding.
Your current working directory is mounted into the container at `/work`, so your code runs in isolation but file changes persist on the host.

## Prerequisites

- **Docker Desktop** ([download][docker-install]) on macOS or Windows, or **Docker Engine** on Linux
- Alternatively, **Podman** ([download][podman-install])
- For sandbox mode: the **Flox CLI** ([install][flox-install])

## Known limitations

**macOS and Windows**
:   Docker on macOS and Windows runs Linux containers.
    Sandbox mode uses Linux packages, not native macOS or Windows packages.
    This is acceptable for CI/CD, AI agent sandboxing, and testing, but is not a substitute for native `flox activate` for day-to-day macOS development.

**First run performance**
:   The first run with a new environment takes 30--60 seconds as it populates the Nix store.
    Subsequent runs reuse the cached store and start in ~5 seconds.

**Services**
:   The `[services]` section of the manifest is not yet supported in sandbox mode.

**Private environments**
:   FloxHub authentication is passed through automatically when using `flox activate --sandbox`.
    Direct Docker usage requires manually mounting the Flox config file.

## Next steps

Follow the [getting started guide](getting-started.md) for a step-by-step walkthrough.

[docker-install]: https://docs.docker.com/get-docker/
[podman-install]: https://podman.io/docs/installation
[flox-install]: ../../install-flox/install.md
