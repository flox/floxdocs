---
title: Node Version Manager (nvm)
description: Using Flox to replace nvm
---

# Node Version Manager (nvm) migration guide

Flox is an environment and package manager that allows you install software from an extensive catalog into individual [environments][environment_concept]{:target="\_blank"}, each of which usually corresponds to a software project. Flox gives you the opportunity to simplify the development workflow used by your team, consolidating various functions into a single command: `flox activate`.

Just like [nvm](https://github.com/nvm-sh/nvm){:target="\_blank"}, Flox allows you to install and activate different versions of Node.js, allowing developers to switch versions as project requirements dictate.

## Why you might want to use Flox instead of nvm
nvm does exactly what it purports to do: it manages Node.js versions simply and effectively. Point notwithstanding, it's also one more dependency that you don't have to worry about if you're using Flox. Consider whether one of the following cases applies to you, or to your team:

* **You work with other engineers who are not JavaScript developers.** Flox will allow your team members who are not TypeScript or JavaScript developers to get up and running on your project, with the correct Node.js version. They won't have to install and use an unfamiliar toolchain in a language with which they might not be familiar. Instead, they can use well known Flox commands to activate their dev environments.
* **You are already using Flox for your non-JS/non-TS projects.** If you are already using Flox for projects written in other languages, you can streamline your development workflow by using it for your TypeScript and JavaScript projects as well. If you can replace a tool that only manages Node.js versions with something that manages _all_ software dependencies, you're well on your way to simplifying your dev workflow.
* **You need to manage versions of other JavaScript runtimes, like Bun or Deno.** While nvm is, as the name denotes, used for managing Node.js versions, that's all it does. You can use Flox to install node, but you can also use it to install different JavaScript runtimes, including [Bun](https://bun.sh/){:target="\_blank"} and [Deno](https://deno.com/){:target="\_blank"}.

## Install Flox
Download and install Flox as described in our [installation instructions][install_flox]{:target="\_blank"}.

## Create a Flox environment in your existing project and install Node.js
Run `flox init` from the relevant project directory (see [creating environments][creating_tutorial]{:target="\_blank"} for details), and then search for the version of Node.js that is currently included in your `.nvmrc`, or in the `"engines"` property of your `package.json`. (Note that node is listed as `nodejs` and variants thereof in the Flox catalog.)

```zsh
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

There is _a lot_ of software in the Flox catalog, so you should have no trouble finding the Node.js version you need. For this project, perhaps you initially decide to install Node.js v20.18.1, "Iron" (LTS).

```zsh
➜  node-project git:(main) ✗ flox install nodejs
✅ 'nodejs' installed to environment 'node-project'
```
## Verify the Node.js version
Now that you've installed Node.js, you activate the Flox environment to verify that it has the the version you expect.

```zsh
➜  node-project git:(main) ✗ flox activate
✅ You are now using the environment 'node-project'.
To stop using this environment, type 'exit'

...
flox [node-project] ➜  node-project git:(main) ✗ node -v
v20.18.1
```

## Update the Node.js version
If you want to install a different node version, you can edit your environment to include the version you need.

Perhaps you decide to upgrade node version to v22. To achieve this, you run `flox uninstall nodejs`, followed by `flox install nodejs_22`.

```zsh
➜  node-project git:(main) ✗ flox uninstall nodejs
🗑️  'nodejs' uninstalled from environment 'node-project'
➜  node-project git:(main) ✗ flox install nodejs_22
✅ 'nodejs_22' installed to environment 'node-project'
➜  node-project git:(main) ✗ flox list
nodejs_22: nodejs_22 (nodejs-22.10.0)
➜  node-project git:(main) ✗ flox activate
✅ You are now using the environment 'node-project'.
To stop using this environment, type 'exit'

...
flox [node-project] ➜  node-project git:(main) ✗ node -v
v22.10.0
```

If you'd like more granular control over the Node.js version to install, you can get the correct Flox catalog version name for the desired Node.js version by running `flox show <package>`:

```zsh
➜  node-project git:(main) ✗ flox show nodejs_22
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

Once you know the specific node 22 versions that are available, you can either run `flox install nodejs_22@nodejs-22.10.0`, or you can run `flox edit` to open up the manifest for the environment, as illustrated below. (For more on the manifest, read [our reference guide][manifest]{:target="\_blank"}.)

Note that you'll need to prepend `nodejs-` to whatever Node.js version number you intend set in the manifest. This is required because of how those versions are stored in the Nix Packages collection.

```toml
...
# List packages you wish to install in your environment inside
# the `[install]` section.
[install]
nodejs = { pkg-path = "nodejs_22", version = "nodejs-22.10.0" }
...
```

## Update the README in your project
At this point, you can replace any nvm-related instructions in your README with corresponding instructions for using Flox. In particular, instead of running `nvm use` to pick up the Node.js version from the `.nvmrc`, you can just run `flox activate`. This will install all the dependencies in your Flox environment, not just node.

## Remove nvm and related artifacts
Now that you're managing your project's Node.js version using Flox, you can `git rm .nvmrc` and commit the result. You're free to repeat the process in other project directories before following the [instructions for uninstalling nvm as listed in the nvm README](https://github.com/nvm-sh/nvm?tab=readme-ov-file#uninstalling--removal){:target="\_blank"}.


[creating_tutorial]: ../creating-environments.md
[environment_concept]: ../../concepts/environments.md
[install_flox]: ../../install-flox.md
[manifest]: ../../reference/command-reference/manifest.toml.md
