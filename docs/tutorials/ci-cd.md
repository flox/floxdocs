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

- `flox/install-flox-action` (installs Flox CLI)
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
        uses: "flox/install-flox-action@v2"

      - name: "Build" # (3)!
        uses: "flox/activate-action@v1"
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

An example CircleCI workflow:

```yaml title=".circleci/config.yml"
version: 2.1

orbs:
  flox: flox/orb@1.0.0

jobs:
  build:
    machine:
      image: ubuntu-2204:current
    steps:
      - checkout
      - flox/install # (1)!
      - flox/activate: # (2)!
          command: "npm run build"
```

1. The `install` command will install the latest Flox version. You can change
   the `channel` and `version` option which allows you to select excatly which
   version of Flox to install.
2. The `activate` command runs a command in the context of a Flox environment.

## GitLab

An example GitLab pipeline:

```yaml title=".gitlab-ci.yml"
build:
  stage: build
  image: ghcr.io/flox/flox:latest # (1)!
  script:
    - flox activate -- npm run build # (2)!
```

1. Use `ghcr.io/flox/flox` that already comes with Flox.
2. Run command in a Flox environment.

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Sharing environments][sharing_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Layering multiple environments][layering_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Customizing the shell hook][customizing_guide]

[sharing_guide]: ./sharing-environments.md
[layering_guide]: ./layering-multiple-environments.md
[customizing_guide]: ./customizing-environments.md
