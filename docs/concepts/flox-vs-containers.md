---
Title: Flox vs. container workflows
Description: How does a Flox workflow differ from a container workflow?
---

# Flox vs. container workflows

Containers are everywhere these days.
They're the de-facto deployment method in the industry,
and they're often used for local development as well as to ensure that every
developer gets the same environment.

Flox gives you these same benefits without many of the papercuts,
but the workflow is slightly different so it's worth exploring.

## Create a new development environment

Let's say you've created a new directory for your project,
`myproject`,
and entered it:

```bash
$ mkdir myproject
$ cd myproject
```

=== "Flox"

    Create a Flox environment for the project via [`flox init`][init]:

    ```bash
    $ flox init
    ```

    This creates a `.flox` directory in `myproject`.
    At this point you can enter the environment,
    but it doesn't provide any new packages or functionality.

=== "Containers"

    Create a new `Dockerfile`.

    ```bash
    $ touch Dockerfile
    ```

    At this point the `Dockerfile` isn't really useable since it doesn't say which
    image to build on top of (there's no `FROM` line).
    Let's pick the latest Ubuntu LTS release.

    ```bash
    $ echo "FROM ubuntu:noble" >> Dockerfile
    ```

    This already adds some variability in that which image this refers to may
    change from moment to moment.

---

## Add packages

Now let's install some packages.
In a typical project there're usually different subsets of packages:

- Packages you don't care about too much, so the latest version will suffice.
- Packages whose versions you want pinned to a recent version.
- Packages that you're behind on updating because upgrading requires significant
  effort.

We'll pick a single package from each category:

- Latest is fine: `curl`
- Specific version: `yarn 1.22`
- Behind: `Python 3.10`

=== "Flox"

    This is pretty straightforward:

    ```bash
    $ flox install curl yarn@1.22 python3@3.10
    ```

    Adding another package at a later date is as simple as running
    `flox install <package>` again.

=== "Containers"

    Add a `RUN` command to your `Dockerfile`:

    ```dockerfile
    RUN apt update && apt install curl npm
    ```

    `yarn 1.22` will be installed via `npm`, so we include that in the `RUN` command.
    This version of Python isn't included in the Ubuntu 24.04 repositories,
    so you must install it from a Personal Package Archive (PPA).
    Do that with another `RUN` command:

    ```dockerfile
    RUN sudo add-apt-repository ppa:deadsnakes/ppa -y && \
        sudo apt update && \
        sudo apt install python3.10
    ```

    This PPA is probably reputable, but now you're managing third-party package
    repositories.

    Adding another package at a later date requires editing the first `RUN`
    command.
    This requires rebuilding later layers,
    such as the one that installs `Python 3.10`.

---

## Configuration

What does it look like to configure your Flox environment compared to a
container?

A Flox environment is configured via a declarative TOML file called a
["manifest"][manifest].
The manifest for the environment created above looks like this:

```toml
version = 1

[install]
curl.pkg-path = "curl"
yarn.pkg-path = "yarn"
yarn.version = "1.22"
python3.pkg-path = "python3"
python3.version = "3.10"

[options]
systems = ["aarch64-darwin", "aarch64-linux", "x86_64-darwin", "x86_64-linux"]
```

One thing to note here is that the manifest defines a cross-platform environment
out of the box to ensure that there are no nasty surprises down the line.

A container is configured via a `Dockerfile`,
which is an imperative sequence of commands.

```dockerfile
FROM ubuntu:noble

RUN apt update && apt install curl npm

RUN sudo add-apt-repository ppa:deadsnakes/ppa -y && \
    sudo apt update && \
    sudo apt install python3.10
```

The upside to a `Dockerfile` is that the commands are familiar
(e.g. `apt install`),
but the order of commands matters and you end up stuffing a lot of commands
into a single `RUN` command to avoid creating extra layers.

## Use the development environment

Let's say you want to do some work in the development environment.
With Flox you're put inside a subshell.
With containers you can use a shell inside the container or connect to the
running container via SSH.
However, with containers you also need to mount in your source code, etc.

=== "Flox"

    Activate the environment:

    ```bash
    $ flox activate
    flox [myproject] $ # now you're in the environment
    ```

    Notice that there wasn't a separate "build" step.
    When you install, uninstall, or edit a Flox environment it's transactionally
    built to ensure that it's always working.

=== "Containers"

    First build the image:

    ```bash
    $ docker build -t myproject .
    ```

    Then start the image (mounting your source) and create a shell inside of it:

    ```
    $ docker run -v ./src:/src myproject -d --name myproject_container
    $ docker exec -it myproject_container bash
    $ # now you're inside the container
    ```

---

## Tear down the development environment

=== "Flox"

    This is pretty straightforward:

    ```bash
    flox [myproject] $ exit
    ```

=== "Containers"

    This is pretty straightforward:

    ```bash
    $ exit # leave the container shell
    $ docker stop myproject_container
    ```

---

## Perform initialization

Let's say you need to move some files around,
ensure a directory exists,
or some other kind of initialization before doing work inside the development
environment.

We'll do a pretend version of this by simply creating a directory `foo`.

=== "Flox"

    This would be performed in the `hook.on-activate` script that's run when
    activating your environment.
    You'll add this by first running `flox edit`,
    and the modifying the `hook` section of your manifest to look like this:

    ```toml
    [hook]
    on-activate = '''
      mkdir foo
    '''
    ```

=== "Containers"

    This would be performed with another `RUN` command,
    creating another layer in the image:

    ```dockerfile
    RUN mkdir foo
    ```

---

## Share the environment with your team

Suppose you work on a team and you've just set up the development environment.
Now you want to share it with your team so you can ensure that everyone has the
same environment.

=== "Flox"

    Since [`flox init`][init] creates a `.flox` directory inside your project,
    you can simply check your project directory into source control.
    Anyone with Flox installed can now work on this project with two commands:

    ```bash
    $ git clone <your project repo>
    $ flox activate
    ```

    Any packages not locally cached would be automatically downloaded.
    Since the Flox environment produces a lockfile each time it is built,
    every developer that does a [`flox activate`][activate] with the same
    lockfile will get the same exact software down to the `git` revisions of the
    upstream source repositories.

    If your Flox environment doesn't need to be tied to this specific project you
    could also push the environment to FloxHub with [`flox push`][push].
    Then your team would activate the environment as a "remote" environment:

    ```bash
    $ # You
    $ flox push
    $ # Your coworker
    $ flox activate -r your_user/myproject
    ```

=== "Containers"

    The `Dockerfile` would be checked into source control,
    then each developer would build the image locally via `docker build`.
    However, since _building_ the image isn't reproducible
    (packages in the repositories may have new updates/bugs, base image may
    have been updated),
    each developer may have a slightly different development environment.

    It's possible to ensure that all of the developers get the same software
    by building the image in a CI system and having developers avoid building
    the image locally.

    - Create a repository or CI rule that builds the development image every
      time the `Dockerfile` changes.
    - Build the image in CI and upload the image to a registry.
    - Developers `docker pull` the image when there are updates.

    This is additional complexity though, and requires extra infrastructure.

---

## Development-time services

In order to mimic the production environment you may want some services running
during development (e.g. a web server, a database, etc).

For this example let's say you want a minimal Caddy server running with some
environment variables set.

=== "Flox"

    First install Caddy:

    ```bash
    $ flox install caddy
    ```

    Then [edit][edit] your manifest to create a new [service][services]:

    ```toml
    [services.server]
    command = "caddy run"
    vars.VAR1 = "var1"
    vars.VAR2 = "var2"
    ```

    Since Flox environments aren't isolated from the host machine's network
    you don't need to map any ports.

    You can start this service from inside the Flox environment with
    [`flox services start`][services-start],
    or you can have it start automatically when entering the Flox environment via
    `flox activate --start-services`.

=== "Containers"

    First create a `docker-compose.yml` file that pulls in a Caddy image:

    ```yaml
    version: "3.8"

    services:
      caddy:
        image: caddy:latest
        container_name: caddy_server
        ports:
          - "80:80"
          - "443:443"
        environment:
          - VAR1=var1
          - VAR2=var2
    ```

    This configuration maps the container's ports so that they're accessible
    from the host machine.

    The service is started separately via `docker-compose up`,
    but you may also add the development container to the `docker-compose.yml`
    file so that it's started at the same time as the server.

---

## Run tests in CI

Say you've done some development and now want to run your changes through CI.

=== "Flox"

    A CI system would activate the Flox environment for the repository and then
    run a specified command inside the environment for each step of the CI job.

    Since a Flox environment contains a lockfile,
    a CI system that runs `flox activate` will get exactly the same software
    as the developer pushing the changes.
    This greatly reduces the number of "it works on my machine" instances.

    Flox provides a number of plugins for CI providers,
    including Github Actions, CircleCI, and GitLab.
    See the [CI/CD tutorial][ci-cd] for more information.

=== "Containers"

    A CI system would either pull the development image from a registry or
    build it if necessary.
    The CI system would then run a specified command inside the container for
    each step in the CI job.

---

## Send artifacts to production

Now that you have a working development environment,
you need to build a container so that it can be deployed.

=== "Flox"

    This feature is still a work in progress in Flox.
    You can create a container from an environment via the
    [`flox containerize`][containerize] command,
    but it doesn't perform a build of an artifact to _run_ in that container.

    We have some exciting things happening in this space!
    If you're interested in early access for this feature,
    see our [early access page][early].

=== "Containers"

    Typically your `Dockerfile` will contain multiple stages,
    possibly a base `builder` stage, a development stage that builds on
    `builder`, and a production stage that contains only the executable.

    You would typically build this image in CI via a `docker build` command
    that targets the production stage.
    CI would also upload the production image to a container registry.

---

[init]: ../reference/command-reference/flox-init.md
[edit]: ../reference/command-reference/flox-edit.md
[install]: ../reference/command-reference/flox-install.md
[push]: ../reference/command-reference/flox-push.md
[containerize]: ../reference/command-reference/flox-containerize.md
[activate]: ../reference/command-reference/flox-activate.md
[services-start]: ../reference/command-reference/flox-services-start.md
[services]: ../concepts/services.md
[manifest]: ../concepts/manifest.md
[early]: https://flox.dev/early/
[ci-cd]: ../tutorials/ci-cd.md
