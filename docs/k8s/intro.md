---
title: "Introduction"
description: "What is Imageless Kubernetes?"
---

Imageless Kubernetes is a new way to run Kubernetes backed by Flox environments rather than container images.
This means that rather than managing image pipelines and constantly rebuilding containers, you now have lightweight Flox environments that *build reproducibly*, with centralized control via FloxHub.
And since Flox environments give you the same set of dependencies no matter where they're run, you can rest easy knowing that the tools you used during development and CI are the same as those running in a Kubernetes pod.

Let's take a closer look at what this buys you.

## Centralized management

Each pod specifies a command to run and the Flox environment to run inside of it.
The syntax is slightly different to a typical pod spec, so the syntax will be explained shortly.
For now, just know that you need to specify a Flox environment to run your command in.

The environment you specify must be an environment that has been pushed to FloxHub because this is where the centralized management magic happens.
Once the environment has been pushed to FloxHub, you get:

- A list of the installed packages and their versions
- A list of the environment variables set by the environment
- The scripts that run on startup
- An audit trail of what changes were made to the environment and by whom

Once an environment has been pushed to FloxHub, FloxHub becomes the source of truth.

## Syntax

A sample pod specification is shown below:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: flox-containerd-demo
  annotations:
    # Required: the FloxHub environment to be activated within the pod
    flox.dev/environment: "limeytexan/echoip"
    # Optional: disable Flox metrics reporting
    # flox.dev/disable-metrics: "false" # default
spec:
  # Required: directs containerd to use the Flox backend
  runtimeClassName: flox
  containers:
    - name: echoip
      # We provide `flox/empty` as a demonstration that the Flox
      # environment requires nothing from the container image.
      image: flox/empty:1.0.0
      # The command to run inside your environment
      command: ["echoip"]
```

In short, you specify the Flox environment as an annotation, then provide a command to run inside the environment via a command to a dummy container (`flox/empty:1.0.0`) that's only a few bytes in size.
As explained above, this workaround is required by Kubernetes pod specification.

## Workflow

Once you create a pod specification and deploy it, the pod will start up with the currently live [generation][generations-concept] of the environment.

Now let's say you want to add a package to the environment running in the pod.
All you need to do is install the package to the environment, and redeploy the pod.
No need to rebuild an image.

Here's what happens under the hood:

- An operator runs `flox install -r myorg/myenv somepackage`.
- This creates a new generation of `myorg`'s `myenv` environment and makes it the live generation.
- Next time the pod is deployed, it will pull the live generation (which now contains `somepackage`)

It's that simple.

## Trying it out

Some cloud providers don't allow you to modify the nodes in the Kubernetes cluster, so for now you are limited to:

- Amazon EKS
- Self-managed Kubernetes

See the [installation][install-section] for more details on installing Imageless Kubernetes to your cluster.

To try out Imageless Kubernetes locally, see the [examples][examples-section], which uses `kind` to create a local Kubernetes cluster.

[generations-concept]: ../concepts/generations.md
[install-section]: ./install/eks.md
[examples-section]: ./examples/kind-demo.md
