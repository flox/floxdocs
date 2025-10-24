---
title: "Authentication"
description: "How to authenticate to FloxHub with Kubernetes on Flox"
---

Kubernetes on Flox (KoF) allows you to run Flox environments in place or on top of container images.
Flox environments are accessed centrally via [FloxHub][floxhub] and managed using the Flox CLI.

In the [introduction][intro] we discussed how annotations are used to instruct KoF which Flox environment to run.
However, we assumed that the referenced environment was publicly available without authentication.
If you plan to use private environments, you will have to authenticate KoF to access FloxHub using your user credentials.

To do so, you need to first login to FloxHub using the Flox CLI using [`flox auth login`][flox_auth], if you haven't done so already.
You then create a new Kubernetes secret:

```bash
flox auth token | kubectl create secret generic floxhub-token --from-file=floxhub-token=/dev/stdin
```

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

      # Required for auth: mount the secret into a known place where KoF can read it.
      volumeMounts:
        - name: secret-volume
          mountPath: "/var/run/secrets/flox.dev"
          readOnly: true
```

[intro]: ./intro.md
[floxhub]: ../concepts/floxhub.md
[flox_auth]: ../man/flox-auth.md
