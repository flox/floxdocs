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

## Mixed Flox/non-Flox pods

Imageless Kubernetes allows mixing Flox and non-Flox-based containers in the same pod, supporting the use of conventional init or sidecar containers combined with Flox-based workloads.
This is accomplished through the use of two annotations: `flox.dev/skip-containers` and `flox.dev/skip-containers-exec`.

`flox.dev/skip-containers` accepts a comma-separated list of containers that will _not_ be modified by the Flox runtime, and will be run as if they were started with the default runtime (e.g. `runc`). This option is best used for sidecars like `vault-agent` or `istio` that should run completely unmodified.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: quotes-app
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "myapp-role"
    flox.dev/environment: "flox/quotes-app"
    # Keep these containers unmodified 
    flox.dev/skip-containers: "vault-agent,vault-agent-init"
  spec:
    containers:
...
    - name: vault-agent
      image: hashicorp/vault:latest
      command: ["/bin/sh", "-ec"]
      args:
      - |
        vault agent -config=/vault/configs/agent.hcl
      env:
      - name: VAULT_ADDR
        value: "http://vault.vault.svc.cluster.local:8200"
      volumeMounts:
      - name: vault-secrets
        mountPath: /vault/secrets

    - name: quotes-app
      image: flox/empty:1.0.0
      command: ["quotes-app-go"]
      volumeMounts:
      - name: vault-secrets
        mountPath: /vault/secrets
        readOnly: true
...
```

`flox.dev/skip-containers-exec` also accepts a comma separated list of containers, but containers specified in this annotation _will_ contain the Flox environment specified in `flox.dev/environment`.

The difference from `skip-containers` is that while `skip-containers-exec` containers will have their main process run from the Flox environment, commands run via `kubectl exec` or equivalent will be run outside of it. This option is best used when you want the container's main workload to run in the Flox environment, but need exec commands (for debugging, health checks, or auxiliary tasks) to run in the base container environment without Flox.

[intro]: ./intro.md
[floxhub]: ../concepts/floxhub.md
[flox_auth]: ../man/flox-auth.md
