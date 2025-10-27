---
title: "Configuration"
description: "Configuring Imageless Kubernetes"
---

# Configuration

## Authentication

Imageless Kubernetes allows you to run Flox environments in place or on top of container images.
Flox environments are accessed centrally via [FloxHub][floxhub] and managed using the Flox CLI.

In the [introduction][intro] we discussed how annotations are used to instruct Imageless Kubernetes which Flox environment to run.
However, we assumed that the referenced environment was publicly available without authentication.
If you plan to use private environments, you will have to authenticate Imageless Kubernetes to access FloxHub using your user credentials.

To do so, you need to first login to FloxHub using the Flox CLI using [`flox auth login`][flox_auth], if you haven't done so already.
You then create a new Kubernetes secret:

```bash
flox auth token | kubectl create secret generic floxhub-token --from-file=floxhub-token=/dev/stdin
```

!!! note "Flox CLI version"
    The user creating the token via `flox auth token` will need at least version 1.7.6 of the Flox CLI.

Finally, you add a secret volume to your pod specification and mount it to `"/var/run/secrets/flox.dev"` inside your container.

A sample specification is shown below:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: flox-containerd-demo
  annotations:
    flox.dev/environment: "limeytexan/echoip"
spec:
  runtimeClassName: flox

  # Required for auth: a secret volume referencing the secret created with
  # `$ kubectl create secret`
  volumes:
    - name: secret-volume
      secret:
        secretName: floxhub-token

  containers:
    - name: empty
      image: flox/empty:1.0.0
      command: ["echoip"]

      # Required for auth: mount the secret into a known place where Imageless Kubernetes can read it.
      volumeMounts:
        - name: secret-volume
          mountPath: "/var/run/secrets/flox.dev"
          readOnly: true
```

## Telemetry

Since Imageless Kubernetes uses the Flox CLI to perform certain operations such as activating your environment, Imageless Kubernetes will report the same telemetry by default that the Flox CLI reports.
This includes information such as:

- Which subcommands were run
- Which shell was used for the activation (Bash, Zsh, etc)
- Whether the environment was remote (e.g. stored on FloxHub) or not
- etc

We also use Sentry for error reporting.
This information helps us focus feature development and maintenance on the areas that deliver the most value for our users.

However, we understand that some users either don't want any information collected or work in an environment that does not allow this kind of information to be collected.
For this reason we offer the ability to disable telemetry.

### Disabling telemetry

When using the Flox CLI directly you can set `FLOX_DISABLE_METRICS=1` in your environment.
With Imageless Kubernetes, you can set an annotation on the pod specification to accomplish the same goal.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: flox-containerd-demo
  annotations:
    flox.dev/environment: "limeytexan/echoip"
    # Disable telemetry
    flox.dev/disable-metrics: "true"
spec:
  runtimeClassName: flox
  containers:
    - name: empty
      image: flox/empty:1.0.0
      command: ["echoip"]
```

[intro]: ./intro.md
[floxhub]: ../concepts/floxhub.md
[flox_auth]: ../man/flox-auth.md
