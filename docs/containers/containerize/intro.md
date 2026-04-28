---
title: "Containerize"
description: "Build traditional OCI container images from Flox environments."
---

# Containerize

[`flox containerize`][containerize-man] exports a Flox environment as a standard OCI container image with all dependencies baked in at build time.
Unlike [thin containers](../thin-containers/intro.md) and [Imageless Kubernetes](../imageless-kubernetes/intro.md), the resulting image does **not** use Flox or the Nix store at runtime --- it's a conventional container image that can be pushed to any registry and run anywhere.

## Consider thin containers first

Before reaching for `flox containerize`, consider whether [thin containers](../thin-containers/intro.md) or [Imageless Kubernetes](../imageless-kubernetes/intro.md) would be a better fit for your use case.
With `flox containerize`, you give up several advantages of the thin-container model:

| | Thin Containers | Containerize |
| --- | --- | --- |
| **Image rebuilds** | Not needed --- environments resolve at startup | Required on every environment change |
| **Caching** | Shared Nix store across all environments | Each image is self-contained |
| **Image size** | Tiny base image; packages from shared store | All packages baked into the image |
| **FloxHub management** | Centralized --- changes propagate automatically | Frozen at build time |
| **Iteration speed** | ~5s startup (after first run) | Rebuild + push + pull cycle |

## When to use `flox containerize`

`flox containerize` is the right choice when deploying to infrastructure that **requires standard container images** and cannot support a mounted Nix store volume:

- Container registries and orchestrators that expect self-contained images (e.g., AWS ECS, Docker Swarm, cloud functions)
- Environments where volume mounts are restricted or unavailable
- Distribution to users who don't have Flox or a Nix store

## What you still get

Even though `flox containerize` uses the traditional model, the images it produces are superior to hand-written Dockerfiles:

- **Fully pinned** --- the same lockfile that drives your development environment drives the image, so you get identical software down to the Git revisions of upstream source repositories
- **Cross-platform** --- define one environment, build images for multiple architectures
- **Reproducible** --- the same lockfile always produces the same image contents
- **Configurable** --- set OCI metadata (ports, volumes, labels, user, working directory) via the manifest's `[containerize.config]` section

## Next steps

Follow the [getting started guide](getting-started.md) to build your first container image from a Flox environment.

See the [`flox containerize` reference][containerize-man] for the full list of CLI options and manifest configuration.

[containerize-man]: ../../man/flox-containerize.md
