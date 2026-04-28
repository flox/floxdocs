---
title: "Getting started with Containerize"
description: "Build a container image from a Flox environment."
---

# Getting started with Containerize

This guide walks you through building a traditional OCI container image from a Flox environment using [`flox containerize`][containerize-man].

!!! tip
    If you don't need a self-contained image, consider using [thin containers](../thin-containers/intro.md) instead.
    Thin containers resolve environments at startup and don't require image rebuilds when your environment changes.

## Prerequisites

- The [Flox CLI][flox-install]
- [Docker][docker-install] or [Podman][podman-install] (required on macOS; optional on Linux)

## 1. Create an environment

Create a new environment and install some packages:

```{ .bash .copy }
mkdir myproject && cd myproject
flox init
flox install hello curl
```

## 2. Build the image

Load the image directly into your container runtime:

```{ .bash .copy }
flox containerize --runtime docker
```

Alternatively, write the image to a file:

```{ .bash .copy }
flox containerize -f myproject.tar
```

You can then load the file into Docker manually:

```{ .bash .copy }
docker load -i myproject.tar
```

!!! note "macOS"
    On macOS, `flox containerize` uses a proxy container (Docker or Podman) to build the Linux image.
    You may be prompted for file-sharing permissions on the first run.

## 3. Run the container interactively

```{ .bash .copy }
docker run --rm -it <image-id>
```

You'll be dropped into a shell with the environment activated --- all your packages and environment variables are available:

```{ .console .no-copy }
[floxenv] $ hello
Hello, world!
[floxenv] $ curl --version
curl 8.x.x ...
```

## 4. Run a command directly

```{ .bash .copy }
docker run --rm <image-id> hello
```

```{ .console .no-copy }
Hello, world!
```

This runs the command inside the activated environment without starting an interactive shell, similar to `flox activate -- hello`.

## 5. Tag and push

Build with a specific tag:

```{ .bash .copy }
flox containerize --tag v1 --runtime docker
```

Then push to a registry:

```{ .bash .copy }
docker tag <image-name>:v1 myregistry.example.com/myproject:v1
docker push myregistry.example.com/myproject:v1
```

## 6. Customize the image

You can configure OCI metadata for the container image in the `[containerize.config]` section of your manifest.
Run `flox edit` and add:

```toml
[containerize.config]
working-dir = "/app"
exposed-ports = ["8080/tcp"]
cmd = ["hello"]
```

See the [`flox containerize` reference][containerize-man] for the full list of configuration options, including `user`, `volumes`, `labels`, and `stop-signal`.

## Next steps

- Read about [how containerize differs from thin containers](../tech.md) at a technical level
- Learn about [thin containers](../thin-containers/intro.md) for faster iteration without image rebuilds
- See the full [`flox containerize` reference][containerize-man] for all CLI options

[containerize-man]: ../../man/flox-containerize.md
[flox-install]: ../../install-flox/install.md
[docker-install]: https://docs.docker.com/get-docker/
[podman-install]: https://podman.io/docs/installation
