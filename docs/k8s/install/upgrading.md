---
title: "Upgrading"
description: "Upgrading Imageless Kubernetes"
---

This guide details how to perform upgrades on Flox and Imageless Kubernetes installed in a cluster.

## Amazon EKS

If a separate node group was created per the [install guidance][eks], then upgrading Flox and the runtime shim
can be accomplished by forcing replacement of the nodes in the cluster.

The configuration as given in the documentation will automatically install the latest version of Flox
and the runtime shim at node startup -- no other action is required.

## Self-managed

On self-managed clusters, both Flox and the runtime shim must be upgraded individually on each node.

For Flox, the [Install Flox][install-flox] page has details for each installation type on how to upgrade.

For the runtime shim, re-running the install command will perform the upgrade.
It can be done as:

```sh
flox activate -r flox/containerd-shim-flox-installer --trust
```

after which, all new pods will be created with the new shim version.

Exising Flox pods will only use the new version once they are restarted.

[eks]: ./eks.md
[install-flox]: ../../install-flox/install.md
