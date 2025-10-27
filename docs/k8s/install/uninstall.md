---
title: "Uninstall"
description: "Uninstalling Imageless Kubernetes from any cluster"
---

This guide describes removing Imageless Kubernetes from a cluster.

First, remove the `RuntimeClass` as:

```sh
kubectl delete runtimeclass flox 
```

Then follow the installation-method specfic guidance below.

## Amazon EKS

If a separate node group was used for Imageless Kubernetes, removing that node group and the `RuntimeClass` is all that is required to uninstall.

### Terraform

If Terraform was used to add a node group to an existing cluster:

- Remove the `eks_managed_node_group` resource from your configuration
- Apply the updated configuration

### eksctl

If `eksctl` was used, remove the node group as:

```sh
eksctl delete nodegroup -f nodegroup.yaml
```

where `nodegroup.yaml` is the file that was used to create it.

Alternatively, remove the node group directly from the AWS management console.

## Self-managed

First, remove the Flox runtime from the `containerd` configuration on each node.

The installer used in the [installation instructions][self-managed] makes a backup of the original configuration
in `/etc/containerd/config.toml.bak.xx` where `xx` is an arbitrary number.

Restore the backup as:

```sh
mv /etc/containerd/config.toml.bak.xx /etc/containerd/config.toml
systemctl restart containerd
```

Then remove the shim from each node as:

```sh
rm /usr/local/bin/containerd-shim-flox-v2
rm -rf /flox
```

And finally, uninstall Flox from each node by following the instructions from the [Uninstall Flox][uninstall-flox] page.

[self-managed]: ./self-managed.md
[uninstall-flox]: ../../install-flox/uninstall.md
