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

We provide an installer in the form of a Flox environment that deploys Imageless Kubernetes by:

- Detecting the installed `containerd` version
- Downloading and installing the correct runtime shim version
- Updating the `containerd` configuration as necessary
- Restarting `containerd`

Details about the installer can be found on its [FloxHub page][shim-installer]; the script is the activation hook for the environment.

Once Flox is installed, the runtime shim can be installed by running the following command as `root` on each node that will host Imageless Kubernetes pods.

```sh
flox activate -r flox/containerd-shim-flox-installer --trust
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
