---
title: "Self-managed Kubernetes"
description: "Installing Imageless Kubernetes to a self-managed Kubernetes cluster"
---

This guide describes general steps for installing Imageless Kubernetes, suitable for self-managed clusters or other Kubernetes distributions (e.g. K3s).

To use Imageless Kubernetes, on each node you will need to:

- Install Flox
- Install the Flox `containerd` runtime shim
- Register the shim with `containerd`
- Register the shim with Kubernetes

!!! note "Imageless Kubernetes requires a minimum `containerd` version of `1.7`."

## Node Configuiration

### Flox Installation

Flox packages and installation instructions for `rpm` and `deb` based distributions are available from the the [Install Flox][install-flox] page.

Flox will need to be installed on each node that will host Imageless Kubernetes pods.

### Runtime shim installation

#### Automatic installation

We provide an installer in the form of a Flox environment that deploys Imageless Kubernetes by:

- Detecting the installed `containerd` version
- Downloading and installing the correct runtime shim version
- Updating the `containerd` configuration as necessary
- Restarting `containerd`

Details about the installer can be found on its [FloxHub page][shim-installer]; the script is executed by the activation hook for the environment.

Once Flox is installed, the runtime shim can be installed by running the following command as `root` on each node that will host Imageless Kubernetes pods.

```sh
flox activate -r flox/containerd-shim-flox-installer --trust
```

#### Manual installation

If you receive a message like:

```sh
containerd not found, skipping flox shim installation
```

when running the installer, but do have `containerd` installed, you can perform the installation process manually.

This may be necessary for Kubernetes distributions like K3s that vendor `containerd`, and put its binaries and configuration in a non-standard location.

1. Create a Flox environment and install the runtime shim.

    ```sh
    mkdir containerd-shim-flox
    cd containerd-shim-flox
    flox init -b
    # use -2x for containerd 2.x, and -17 for 1.7
    flox install containerd-shim-flox-2x 
    ```

2. Create a symlink from the Flox environment to `/usr/local/bin`.

    ```sh
    ln -s $PWD/.flox/run/x86_64-linux.containerd-shim-flox.run/bin/containerd-shim-flox-v2 /usr/local/bin/containerd-shim-flox-v2

    ```

3. Add the Flox runtime configuration to the `containerd` `config.toml`.
Check the `version` line at the beginning of the file and use the matching configuration below.

    !!! note "Note"
        This is usually in `/etc/containerd`, but on K3s, it is in `/var/lib/rancher/k3s/agent/etc/containerd`.

        See the [K3s documentation](https://docs.k3s.io/advanced#configuring-containerd) for more details on that specific implementation.

    ```toml title="version = 2"
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.flox]
        runtime_path = "/usr/local/bin/containerd-shim-flox-v2"
        runtime_type = "io.containerd.runc.v2"
        pod_annotations = [ "flox.dev/*" ]
        container_annotations = [ "flox.dev/*" ]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.flox.options]
        SystemdCgroup = true
    ```

    ```toml title="version = 3"
    [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.flox]
      runtime_path = "/usr/local/bin/containerd-shim-flox-v2"
      runtime_type = "io.containerd.runc.v2"
      pod_annotations = [ "flox.dev/*" ]
      container_annotations = [ "flox.dev/*" ]
      [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.flox.options]
        SystemdCgroup = true
    ```

4. Restart `containerd`

    ```sh
    systemctl restart containerd
    # if needed
    systemctl restart k3s
    ```

## Kubernetes Configuration

A [RuntimeClass][runtime-class] is used to expose the runtime to Kubernetes such that it can be utilized to create pods.

We recommend labeling nodes that have the runtime shim installed to ensure Flox pods are only scheduled on them.

1. Label your nodes with the following command:

    ```sh
    kubectl label node <node-name> "flox.dev/enabled=true"
    ```

2. Update the `nodeSelector` in the following `RuntimeClass` definition to match the `label` specified above.

    ```yaml title="RuntimeClass.yaml"
    apiVersion: node.k8s.io/v1
    kind: RuntimeClass
    metadata:
      name: flox
    handler: flox
    scheduling:
      nodeSelector:
        flox.dev/enabled: "true"
    ```

3. Apply this resource with the following command:

    ```sh
    kubectl apply -f RuntimeClass.yaml
    ```

The `nodeSelector` ensures that Flox pods will only be scheduled on nodes with the Flox runtime installed.

## Conclusion

Once the nodes have Flox and the shim installed, you are ready to create pods using the Flox runtime.

A sample `Pod` manifest is available in the [Introduction][intro-section], but any Kubernetes resource that creates a pod (e.g. `Deployment`) can be used by setting the `runtimeClassName` parameter to `flox`.

[intro-section]: ../intro.md
[install-flox]: ../../install-flox/install.md
[shim-installer]: https://hub.flox.dev/flox/containerd-shim-flox-installer
[runtime-class]: https://kubernetes.io/docs/concepts/containers/runtime-class/
