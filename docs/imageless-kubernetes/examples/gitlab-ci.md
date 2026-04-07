---
title: "GitLab CI"
description: "Demo running GitLab CI with Imageless Kubernetes"
---

You can use Imageless Kubernetes in many applications where you would rely on a conventional image-based workflow.

This example shows how you can use Imageless Kubernetes with GitLab CI, running jobs inside of the same Flox environment you use for development.

## GitLab runner configuration

To configure your GitLab runner to run Imageless Kubernetes pods, add this section to the runner's `config.toml`:

```toml
[[runners]]
  [runners.kubernetes]
    namespace = {% raw %}"{{ default .Release.Namespace .Values.runners.jobNamespace }}"{% endraw %}
    runtime_class_name = "flox"
    image = "flox/empty:1.0.0"
    pod_annotations_overwrite_allowed = '^flox\.dev.*'
    [runners.kubernetes.pod_annotations]
      "flox.dev/skip-containers" = "init-permissions,helper"
      "flox.dev/skip-containers-exec" = "build"
      "flox.dev/activate-mode" = "dev" # optional
```

!!! note "Note"
    These options can also be passed as part of the job definition in `.gitlab-ci.yml`, see the [GitLab documentation][gitlab-k8s-docs] for more details.

These settings will start all GitLab job pods using the Flox runtime, with an empty container image, and allow setting additional annotations (e.g. `flox.dev/environment`) on a per-job basis.

The `flox.dev/skip-containers` and `flox.dev/skip-containers-exec` annotations are necessary to allow GitLab's init containers to get the code and job script into build container for execution.

`flox.dev/activate-mode` is set to make build dependencies available to the job script.

See the [configuration][config] page for more details on annotations.

## GitLab job configuration

Once you've configured the runner, you will need to supply each job with the desired `flox.dev/environment` annotation, which can be done in `.gitlab-ci.yml`:

```yaml
stages:
  - hello

hello-job:
  stage: hello
  variables:
    KUBERNETES_POD_ANNOTATIONS_1: "flox.dev/environment=flox/hello"
  script:
    - hello
```

where the value of the annotation is the name of an environment from [FloxHub][floxhub].

!!! note "Note"
    The `flox.dev/environment` annotation is *not* optional -- pods will fail to start if it is not supplied.

## Conclusion

Now, any job you target to this runner will be executed with Imageless Kubernetes.

If you utilize the same Flox environment used for development, you will be able to seamlessly test with the exact same packages, regardless of what system or architecture is used.

Since the CI environment doesn’t rely on a container image, updates are instant: run `flox push`, and the job will pick up the changes automatically.

[gitlab-k8s-docs]: https://docs.gitlab.com/runner/executors/kubernetes/
[config]: ../config.md
[floxhub]: ../../concepts/floxhub.md
