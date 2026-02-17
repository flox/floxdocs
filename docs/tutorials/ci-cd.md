---
title: Running Flox in CI/CD
description: Integrate with your favorite CI/CD platform.
---

# Continuous integration/delivery (CI/CD)

Continuous integration (CI) and Continuous delivery (CD) is essential in today's software development cycle.
With Flox the **exact** same set of software can be used for local development and a CI/CD pipeline.
This feature works out of the box with Flox because Flox environments work cross-platform and reproducibly by default.
This means that you can spend less time debugging your CI/CD pipeline and more time developing your software.

Let's look at how you can use Flox with a variety of CI/CD platforms.
For the following examples assume that you have a repository that contains a Flox environment, and assume that you've installed some Node.js dependencies for your project.

## Github Actions

Flox provides two different actions that you can use in a GitHub Actions workflow:

- `flox/install-flox-action`: This action installs the Flox CLI so you can run Flox commands as you would locally. At some point you would typically run `flox activate -c "<your command>"` with this action to run a command inside the Flox environment.
- `flox/activate-action`: This action allows you to skip activating the environment yourself and simply provide the command that you would like to run in the environment.

Note that the `flox/install-flox-action` is still required if you want to use `flox/activate-action`.

Here is an example workflow that installs the Flox CLI, runs `npm run build`
inside the project's environment, and runs `netlify deploy` inside a FloxHub
environment:

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

    - name: Activate remote environment
      uses: flox/activate-action@v1
      with:
        environment: my-username/my-netlify-env
        command: netlify deploy
```

1. You are looking at an example project, your project will probably look a little different. Important parts of how to integrate Flox with Github Actions are highlighted below.
2. `flox/install-flox-action` will install the latest version of Flox.
3. `flox/activate-action` allows you to run a command inside the Flox environment.

## CircleCI

There is a [Flox Orb](https://github.com/flox/flox-orb) that helps you use Flox inside CircleCI.
Similar to GitHub Actions there is a `flox/install` step and a separate `flox/activate` step.

Here is an example CircleCI workflow that installs Flox and runs `npm run build` inside the environment:

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

1. The `install` command will install the latest Flox version. You can change the `channel` and `version` options which allow you to select exactly which version of Flox to install. The `channel` option will install the latest version from the specified channel, and the `version` option will install a specific version.
2. The `activate` command runs a command in the context of a Flox environment.

## GitLab

To run Flox in a GitLab pipeline you use a container image with Flox preinstalled.
Flox provides the `ghcr.io/flox/flox` image for you to use in your pipelines.
Inside the container you have access to the full Flox CLI, so running a command in the container looks the same as it would locally: `flox activate -c "<your command>"`.

Here is an example GitLab pipeline that uses a Flox container to run `npm run build` inside the environment:

```yaml title=".gitlab-ci.yml"
build:
  stage: build
  image: ghcr.io/flox/flox:latest # (1)!
  script:
    - flox activate -c "npm run build" # (2)!
```

1. Use the `ghcr.io/flox/flox` container image, which comes with Flox already installed.
2. Run a command in the Flox environment.

## Suggestions

Now that you know _how_ to use your Flox environment in CI/CD, the world is your oyster.
Here are some suggestions for things you can do with your Flox environment in CI:

- Run a linter to ensure that new changes adhere to your team's style.
- Use [flox containerize][containerize] to build a container from your environment to deploy elsewhere.
- Build artifacts for multiple systems.
- Run a link checker over your documentation.

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Sharing environments][sharing_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Layering multiple environments][layering_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Customizing the shell hook][customizing_guide]

[sharing_guide]: ./sharing-environments.md
[layering_guide]: ./layering-multiple-environments.md
[customizing_guide]: ./customizing-environments.md
[containerize]: ../man/flox-containerize.md
