---
title: "Troubleshooting"
description: "Troubleshooting Imageless Kubernetes installation"
---

This guide describes possible issues and solutions that may arise during the installation of Imageless Kubernetes.

## Pods stuck in `ContainerCreating`

If your pods are stuck in the `ContainerCreating` state with a message like `no runtime for "flox" is configured`, the shim installation may have been disrupted or failed.

### Configuration conflicts

The Flox additions to `/etc/containerd/config.toml` may be getting overridden by competing entries in an imported configuration file.

Verify the Flox runtime configuration is present in the active containerd config:

1. Dump the active containerd configuration and verify the Flox runtime is present:

    ```bash
    containerd config dump | grep -A 10 "flox"
    ```

2. Check if `containerd config dump` has an `imports` section that might be loading other configuration files.

3. Confirm the relevant sections exist in the output:

    ```toml
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.flox]
        runtime_path = "/usr/local/bin/containerd-shim-flox-v2"
        runtime_type = "io.containerd.runc.v2"
        pod_annotations = [ "flox.dev/*" ]
        container_annotations = [ "flox.dev/*" ]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.flox.options]
        SystemdCgroup = true
    ```

4. If the configuration is missing or incorrect, and an `imports` section is present, you may need to manually add the Flox runtime section to the competing imported file and restart `containerd`.

!!! note "Note"
    This scenario is more likely if the NVIDIA Container Toolkit is installed on the same node as Imageless Kubernetes.

### EKS node shim installation failure

The Flox `containerd` shim may have failed to install properly on the EC2 instance during setup.

Check the system logs in the EC2 console to identify any errors:

1. Navigate to the EC2 console and select your instance.
2. Click **Actions** → **Monitor and troubleshoot** → **Get system log**.
3. Review the logs for any errors related to containerd or the Flox shim installation.
