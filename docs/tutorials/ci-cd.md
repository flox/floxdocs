---
title: Continuous integration/delivery (CI/CD)
description: Integrate with yout favorite CI/CD platform.
---

# Continuous integration/delivery (CI/CD)

Continuous integration (CI) and Continuous delivery (CD) is essetial in todays
software development cycle. Flox environments can take you CI/CD pipelines to
the next level, making them robust and reproducible. Let us look how can you
use Flox with some of the CI/CD platforms.


## Github Actions

An example GitHub workflow.

```yaml title=".github/workflows/ci.yml"
name: "CI"

... # (1)!

jobs:

  build:
    name: "Build website"
    runs-on: "ubuntu-latest"
    steps:
      - name: "Checkout"
        uses: "actions/checkout@v4"

      - name: "Install Flox" # (2)!
        uses: "flox/install-flox-action@main"

      - name: "Build" # (3)!
        uses: "flox/activate-action@main"
        with:
          command: npm run build

      ...

```

1. You are looking at an example project, your project will probably look a
   little different. Important parts of how to integrate Flox with Github
   Actions are highlighted bellow.
2. `flox/install-flox-action` will install latest version Flox.
3. `flox/activate-action` allows you to run a command inside the Flox
   environment.



## GitLab CI/CD

TODO

## CircleCI

TODO


