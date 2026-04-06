---
title: "Flox in Containers"
description: "Run Flox environments inside containers for isolation, reproducibility, and fast iteration."
---

# Flox in Containers

Flox environments can run inside containers, giving you isolated, reproducible execution with the same packages you use during development.
The key difference from traditional container workflows is that packages live in a shared [Nix store][nix-store] mounted into the container rather than baked into the image.
This eliminates image rebuilds, enables shared caching across environments, and dramatically speeds up iteration.

## Choosing an approach

Flox offers three ways to run environments in containers.
The first two use the thin-container model described above; the third is a traditional approach included for compatibility.

### Thin Containers (Docker / Podman) {: .recommended }

**Recommended for: local development, CI/CD, AI agent sandboxing**

Run any FloxHub environment in a Docker or Podman container with a single command, or use the `--sandbox` flag on `flox activate` for a seamless experience.
Packages are cached in a shared Nix store volume, so only the first run is slow (~30-60s); subsequent runs start in ~5 seconds.

No image builds. No Dockerfiles. No image pipelines.

[Get started with Thin Containers :material-arrow-right:](thin-containers/intro.md){ .md-button }

### Imageless Kubernetes

**Recommended for: production Kubernetes workloads**

Run Kubernetes pods backed by Flox environments instead of container images.
A containerd shim resolves environments from FloxHub at pod startup, giving you centralized management, an audit trail of changes, and the same software you used during development.

[Get started with Imageless Kubernetes :material-arrow-right:](imageless-kubernetes/intro.md){ .md-button }

### Containerize

**Traditional approach: when standard OCI images are required**

[`flox containerize`][containerize-man] builds a self-contained OCI image from a Flox environment with all dependencies baked in.
Unlike thin containers and Imageless Kubernetes, the resulting image does **not** use Flox or the Nix store at runtime --- it's a conventional container image.

Use this only when deploying to infrastructure that requires standard container images and cannot support the thin-container model.
The trade-offs are significant:

- Images must be rebuilt every time the environment changes
- No shared caching --- each image is self-contained
- Larger image sizes compared to the thin-container approach
- No centralized management via FloxHub

[Get started with Containerize :material-arrow-right:](containerize/intro.md){ .md-button }

## How it works

All three approaches build on the same foundation: Flox environments backed by Nix.
See [How it works](tech.md) for the technical details of how packages are resolved and mounted inside containers.

[nix-store]: https://nix.dev/manual/nix/latest/store/
[containerize-man]: ../man/flox-containerize.md
