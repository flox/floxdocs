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

There are two actions that you can use in a Github workflow:
- `flox/install-flox-action` (r
- `flox/activate-action` (runs command in the context of Flox environment)

An example GitHub workflow:

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
        uses: "flox/install-flox-action@2"

      - name: "Build" # (3)!
        uses: "flox/activate-action@1"
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


## CircleCI

There is a [Flox Orb](https://github.com/flox/flox-orb) that can help you use
Flox inside CircleCI.

An example GithHub workflox:


```yaml title=".circleci/config.yml"
version: 2.1

orbs:
  flox: flox/orb@1.0.0

workflows:
  build-website:
    jobs:
      - flox/install # (1)!
      - flox/activate: # (2)!
          command: "npm run build"
```

1. The `install` command will install the latest Flox version. You can change
   the `channel` and `version` option which allows you to select excatly which
   version of Flox to install.
2. The `activate` command runs a command in the context of a Flox environment.


## GitLab CI/CD

