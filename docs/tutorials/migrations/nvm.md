---
title: Node Version Manager (nvm)
description: Using Flox to replace nvm
---

# Node Version Manager (nvm) migration guide

Flox is an environment and package manager that allows you to install software from an extensive catalog into individual [environments][environment_concept]{:target="\_blank"}, each of which usually corresponds to a software project. Flox gives you the opportunity to simplify the development workflow used by your team, consolidating various functions into a single command: `flox activate`.

Just like [nvm](https://github.com/nvm-sh/nvm){:target="\_blank"}, Flox allows you to install and activate different versions of Node.js, enabling you to switch versions as project requirements dictate. _Unlike_ nvm, however, Flox also allows you to install just about any software you need, including databases and packages from language ecosystems like Python, Rust, Go, Java, Ruby, and others.

## Why you might want to use Flox instead of nvm
nvm does exactly what it purports to do: it manages Node.js versions simply and effectively. Point notwithstanding, it's also one more dependency that you don't have to worry about if you're using Flox. Consider whether one of the following cases applies to you, or to your team:

* **You work on a team with members who have diverse skill sets, and you want to have a single entrypoint for development, regardless of language ecosystem.** No matter what languages and technologies your team is comfortable with, they can use the same Flox commands to spin up their local dev environments. For example, instead of asking a Java developer who uses a Linux machine to install nvm in order to get the right node version for your project, you can offer a better solution. That developer can use the same Flox commands they use to activate their own projects to activate the dev environment for your node project, which you develop on your Mac.
* **You want a tool that allows you to manage Node.js versions as well as other dependencies.** Having a single-use tool like nvm is fine, but what if you could install node, PostgreSQL, nginx, etc. with a single command? Flox lets you do just that. It also [allows you to configure and run services][services]{:target="\_blank"}, the latter of which you can do simply by adding the `--start-services` argument to `flox activate`.
* **You need to use [`node-gyp`](https://github.com/nodejs/node-gyp){:target="\_blank"} to compile native add-on modules for Node.js, and you want to be sure you have the right version of Python, [Make](https://www.gnu.org/software/make/){:target="\_blank"}, [GCC](https://gcc.gnu.org/){:target="\_blank"}, [Clang](https://clang.llvm.org/get_started.html), and other dependencies.** As a Flox user, you can be certain you'll install versions of these dependencies that are compatible with the node version in your environment. This is all thanks to Nix Packages, which is the underlying software repository on which the Flox Catalog is based.
* **You need to manage versions of other JavaScript runtimes, like Bun or Deno.** While nvm is, as the name denotes, used for managing Node.js versions, that's all it does. You can use Flox to install node, but you can also use it to install different JavaScript runtimes, including [Bun](https://bun.sh/){:target="\_blank"} and [Deno](https://deno.com/){:target="\_blank"}.

## Install Flox
Download and install Flox as described in our [installation instructions][install_flox]{:target="\_blank"}.

## Create a Flox environment in your existing project and install Node.js
Navigate to your project's directory and run this command to initialize a Flox environment:

```sh
flox init
```

After that's done, you can search for the version of Node.js that is currently included in your `.nvmrc`, or in the `"engines"` property of your `package.json`. (Note that node is listed as `nodejs` and variants thereof in the Flox Catalog.)

```sh
flox search nodejs
```

When you search for Node.js, you'll see output like this in your terminal:

```console
➜  node-project git:(main) ✗ flox search nodejs
nodejs       Event-driven I/O framework for the V8 JavaScript engine
nodejs_14    Event-driven I/O framework for the V8 JavaScript engine
nodejs_16    Event-driven I/O framework for the V8 JavaScript engine
nodejs_18    Event-driven I/O framework for the V8 JavaScript engine
nodejs_19    Event-driven I/O framework for the V8 JavaScript engine
nodejs_20    Event-driven I/O framework for the V8 JavaScript engine
nodejs_21    Event-driven I/O framework for the V8 JavaScript engine
nodejs_22    Event-driven I/O framework for the V8 JavaScript engine
nodejs_23    Event-driven I/O framework for the V8 JavaScript engine
nodejs-10_x  Event-driven I/O framework for the V8 JavaScript engine

Showing 10 of 67 results. Use `flox search nodejs --all` to see the full list.

Use 'flox show <package>' to see available versions
```

There is _a lot_ of software in the Flox Catalog, so you should have no trouble finding the node version you need. We recommend that you install one of the `nodejs` packages with a numerical suffix (e.g., `nodejs_18` or `nodejs_22`), rather than `nodejs`, which is the latest stable version of node from the perspective of the Nix Packages maintainers. The `nodejs` package may not get a new version until all the other Nix packages that depend on that specific Node.js version have been updated for compatibility, which could be a long while after an official Node.js release.

At any rate, for this project, perhaps you decide to install Node.js v20.18.1. You can start by running the following command:

```sh
flox install nodejs_20
```

This should yield the following output:

```console
➜  node-project git:(main) ✗ flox install nodejs_20
✅ 'nodejs_20' installed to environment 'node-project'
```

## Verify the Node.js version
Now that you've installed node, you activate the Flox environment to verify that it has the the version you expect.

```sh
flox activate
```

When you activate the environment, you'll see output like this in your terminal:

```console
➜  node-project git:(main) ✗ flox activate
✅ You are now using the environment 'node-project'.
To stop using this environment, type 'exit'
```

Within the active Flox environment, you can verify the node version as follows:

```sh
node -v
```

This command should give you the output you expect, namely the version of node available in your shell:

```console
flox [node-project] ➜  node-project git:(main) ✗ node -v
v20.18.1
```

## Add Node.js and associated dependencies to a package group (optional)
If you need an older version of node in your environment, we recommend that you specify a package group in your manifest to ensure that you can still install the latest versions of other software in your environment. (For more on the manifest and on package groups, read [our reference guide][manifest]{:target="\_blank"}.)

At this point, you should run the following command to edit the Flox environment configuration manually:

```sh
flox edit
```

Now you can edit the `manifest.toml` as illustrated below.

```toml
...
[install]
nodejs_20 = { pkg-path = "nodejs_20", pkg-group = "node-toolchain" }
...
```

## Install other dependencies using Flox (optional)
Assuming your project is like most Node.js applications, you probably have dependencies other than node to install. In this case, maybe you need PostgreSQL and nginx. Fortunately, you can install both using Flox, in the same way in which you installed node.

```sh
flox install postgresql nginx
```

Running this command will install both dependencies to the Flox environment.

```console
flox [node-project] ➜  node-project git:(main) ✗ flox install postgresql nginx
✅ 'postgresql' installed to environment 'node-project'
✅ 'nginx' installed to environment 'node-project'
```
Now you have everything you need to develop locally, and you didn't have to figure out how to install [nginx](https://nginx.org/en/docs/install.html){:target="\_blank"} and [PostgreSQL](https://www.postgresql.org/download/){:target="\_blank"} individually.

## Update the Node.js version
If you want to install a different node version, you can always update your environment to include the version you need. For example, let's say you're upgrading your project to Node.js v22. The best way to get the correct Flox Catalog version name for your desired version is to run `flox show <package>`:

```sh
flox show nodejs_22
```

Now you can see all the available versions of Node.js v22 in the Flox Catalog.

```console
flox [node-project] ➜  node-project git:(main) ✗ flox show nodejs_22
nodejs_22 - Event-driven I/O framework for the V8 JavaScript engine
    nodejs_22@nodejs-22.10.0
    nodejs_22@nodejs-22.9.0
    nodejs_22@nodejs-22.8.0
    nodejs_22@nodejs-22.6.0
    nodejs_22@nodejs-22.5.1
    nodejs_22@nodejs-22.4.1
    nodejs_22@nodejs-22.3.0
    nodejs_22@nodejs-22.2.0
    nodejs_22@nodejs-22.0.0

```

Once you know what's available, you can run the edit command to open up the manifest for the environment:

```sh
flox edit
```

You can now set your desired node version directly in the manifest, and then save your changes. Note that you'll need to prepend `nodejs-` to whatever Node.js version number you intend to set in the manifest. This is required because of how those versions are stored in the Nix Packages collection.

(If you omit the specific version, you will get the latest version of `nodejs_22` that's compatible with everything in your environment. If you have a `pkg-group` set but no specific `version`, you'll get the latest version that's compatible with the rest of the software in the package group.)

```toml
...
[install]
nodejs_22 = { pkg-path = "nodejs_22", pkg-group = "node-toolchain", version = "nodejs-22.10.0" }
...
```

## Update the README in your project
At this point, you can replace any nvm-related instructions in your README with corresponding instructions for using Flox. In particular, instead of running `nvm use` to pick up the Node.js version from the `.nvmrc`, you can just run `flox activate`. This will install all the dependencies in your Flox environment, not just node.

## Remove nvm and related artifacts
Now that you're managing your project's Node.js version using Flox, you can `git rm .nvmrc` and commit the result. You're free to repeat the process in other project directories before following the [instructions for uninstalling nvm as listed in the nvm README](https://github.com/nvm-sh/nvm?tab=readme-ov-file#uninstalling--removal){:target="\_blank"}.


[environment_concept]: ../../concepts/environments.md
[install_flox]: ../../install-flox.md
[manifest]: ../../reference/command-reference/manifest.toml.md
[services]: ../../concepts/services.md
