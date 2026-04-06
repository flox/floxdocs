---
title: "Web server with Redis"
description: "Demo running a simple web server backed by Redis on kind"
---

With Imageless Kubernetes, you can run a container just like in any other
Kubernetes deployment, but you don't have to build a container image.

To demonstrate this, we'll run a simple web server backed by Redis using two
Flox environments.

## Running the example

The entirety of this example can be run locally with the following commands:

```bash
git clone https://github.com/flox/flox-kind-demo.git
cd flox-kind-demo
flox activate
just up
```

This starts a local Kubernetes cluster using `kind` and deploys a web server
backed by Redis.

To fetch something from the web server, run:

```bash
curl localhost:3000/quotes/0
```

## Quotes app environment

The example runs a deployment of [`flox/quotes-app`](https://hub.flox.dev/flox/quotes-app), which is just like any other
Kubernetes deployment, but with a few key differences.
Here's a snippet from the deployment manifest:

```yaml
metadata:
  labels:
    app: quotes
  annotations:
    flox.dev/environment: "flox/quotes-app"
spec:
  runtimeClassName: flox
  containers:
    - name: quotes
      image: flox/empty:1.0.0
      command: ["quotes-app-go", "-r", "redis:6379"]
```

The full deployment manifest can be found in the
[flox-kind-demo repo](https://github.com/flox/flox-kind-demo/blob/main/quotes.yaml).

There are two key lines needed to run the container using a Flox environment
instead of a container image:

- Specifying `runtimeClassName: flox` runs the container using the Flox
  containerd shim.
- The annotation `flox.dev/environment: "flox/quotes-app"` specifies the Flox
  environment to use to bootstrap the container filesystem instead of a container image

Just as with any container, you can specify a startup command, which is
`["quotes-app-go", "-r", "redis:6379"]` in this case.

When the container starts, the [`flox/quotes-app`](https://hub.flox.dev/flox/quotes-app) Flox environment is pulled from FloxHub and bind mounted into the container.
This environment contains the [`flox/quotes-app-go`](https://hub.flox.dev/packages/flox/quotes-app-go) package, which is a simple web server published to FloxHub.
When the container starts, the environment is activated, and then `quotes-app-go` is run inside the activated environment.

### Redis environment

The `quotes-app-go` server uses a Redis instance running in a second deployment.
Just like the first pod, rather than specifying a container image, the Redis
deployment runs the environment `flox/redis` which is pulled from
[hub.flox.dev/flox/redis](https://hub.flox.dev/flox/redis).

Here's the relevant snippet from the Redis deployment manifest:

```yaml
metadata:
  labels:
    app: redis
  annotations:
    flox.dev/environment: "flox/redis"
spec:
  runtimeClassName: flox
  containers:
    - name: redis
      image: flox/empty:1.0.0
      command: ["redis-server", "--daemonize", "no", "--dir", "/data", "--bind", "0.0.0.0", "--protected-mode", "no" ]
      volumeMounts:
        - name: redis-data
          mountPath: /data
```

The full deployment manifest can be found in the
[flox-kind-demo repo](https://github.com/flox/flox-kind-demo/blob/main/redis.yaml).

## Updating the deployment

Because the environment is hosted on FloxHub, there's no need to rebuild a
container image to update the deployment.
After a change to `quotes-app-go`, updating the deployment would require running
a `flox publish` for `quotes-app-go` and a `flox upgrade -r flox/quotes-app`.
After that, restarting a pod will pull the latest generation of the environment.
This allows deploying software with the reproducibility of a container, but
without the overhead of having to rebuild an entire container image when iterating.

## Cleaning up

To tear down the local kind cluster, run:

```bash
just down
```
