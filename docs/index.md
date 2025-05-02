---
title: Introduction
description: What is Flox?

---

<!-- shut up linter -->
<!-- markdownlint-disable-file MD033 -->
<!-- markdownlint-disable-file MD009 -->
<!-- markdownlint-disable-file MD022 -->
<!-- markdownlint-disable-file MD030 -->
<!-- markdownlint-disable-file MD012 -->
<!-- markdownlint-disable-file MD032 -->

# What is Flox?

Flox is a next-generation, language-agnostic package and environment manager.   

  - Define everything your environment needs—packages, tools, environment variables, and services—in one manifest.  
  - Switch between environments easily, share them with your team, and keep everything in version control.   
  - Use the same setup across macOS and Linux, on both x86 and ARM.     

Flox achieves isolation through pre-configured sub-shells, not containers, so it works seamlessly with your existing tools, shells, and dotfiles. Under the hood, Flox uses Nix to ensure reproducibility—without requiring you to learn Nix.    

Flox makes it easy to work locally, test in CI, and deploy to production—all with the same environment.


 <iframe width="550" height="300" src="https://www.youtube.com/embed/aidi5svDml8?si=rrgQ6a0oQzdFNgWs" title="What is Flox?" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> 

---

## Get Started
<div class="grid cards" markdown>

-   :octicons-terminal-24:{ .lg .middle } __Quick start with the Flox CLI__

    ---

    Install `flox` with `apt`, `yum`, `brew`, or a system installer to get your dev 
    environment set up in minutes.

    [:octicons-arrow-right-24: Download & Install][install_flox]

    [:octicons-arrow-right-24: Flox in 5 minutes][flox_5_minutes]
    
    [:octicons-arrow-right-24: Search packages in FloxHub][floxhub_packages]{:target="_blank"}

-   :material-nix:{ .lg .middle } __Already using Nix? Start here__

    ---

    Flox brings the power of Nix to your team, and can simplify your workflows too.

    [:octicons-arrow-right-24: Install Flox with flakes or profiles](install-flox.md?h=nix#__tabbed_1_6){:target="_blank"}

    [:octicons-arrow-right-24: Flox brings Nix to your teams](https://flox.dev/blog/its-time-to-bring-nix-to-work/){:target="_blank"}

    [:octicons-arrow-right-24: Use flakes in Flox](https://flox.dev/blog/extending-flox-with-nix-flakes/){:target="_blank"}

</div>

Guides for getting started in just a few of the many languages Flox supports:

[Node :simple-nodedotjs:](https://flox.dev/blog/using-flox-to-create-portable-reproducible-nodejs-environments/){ .md-button }
[Go :fontawesome-brands-golang:](https://flox.dev/blog/using-flox-to-create-portable-reproducible-go-environments/){ .md-button }
[Python :fontawesome-brands-python:](https://flox.dev/blog/using-flox-to-create-portable-reproducible-python-environments/){ .md-button }
[Rust :fontawesome-brands-rust:](https://flox.dev/blog/a-real-world-rust-project-with-flox/){ .md-button }
[Ruby :material-language-ruby:](https://flox.dev/blog/making-ruby-projects-easier-to-share/){ .md-button }

---

## Why Flox?

We encounter the same challenges, no matter the stack: inconsistent environments, dependency drift, and brittle build processes that don’t scale well across machines, teams, or deployment targets. Current solutions often add complexity and fragmentation.

Flox takes a different approach: it provides a consistent, language-agnostic workflow for managing environments, from local development to CI to production.

Use Flox to solve three common use cases: 

- Reproducible dev environments
- Reliable package management across systems 
- Consistent builds from local to production

### __Reproducible dev environments__

Set up a [local developer environment](https://flox.dev/docs/tutorials/creating-environments/) that will work the same across multiple system types and architectures. Seamlessly switch between development environments across multiple language ecosystems using a consistent, unified workflow.

Declare all the packages, activation scripts, environment variables and [services](https://flox.dev/docs/concepts/services/) needed to reproduce the environment in a simple manifest that can be checked into [version control along with your source code](https://flox.dev/blog/flox-and-teams-managing-your-code-and-your-runtime-environment-in-just-one-place/).

Once your environment is configured, you can simplify the setup instructions in your README to a single command (`flox activate`), making it easy to [share environments](https://flox.dev/blog/flox-and-teams-using-shared-flox-environments/) and [onboard new developers](https://flox.dev/blog/flox-and-teams-onboarding-made-easy-with-github-and-flox/).


### __Cross-platform package management for your whole system__

Set up your [default environment](https://flox.dev/docs/tutorials/default-environment/) with a set of 
packages that you always want available, whether you're on macOS or Linux—x86 or ARM.

Then, when you need to [set up a new laptop](https://flox.dev/blog/setting-up-a-new-laptop-made-easy-with-flox/
), or [keep multiple machines in sync](https://flox.dev/docs/tutorials/sharing-environments/#always-using-the-same-environment-across-multiple-devices
), you can be sure you're using the exact same versions, no matter when or where you need them. 

If you're already using Homebrew, you can easily [migrate or use Homebrew and Flox together](https://flox.dev/docs/tutorials/migrations/homebrew/).



### __Consistent builds from local to CI to production__

Flox lets you define what an environment _is_ in a way that can be reused across local dev, CI, and production. 
Leverage [pre-built integrations](https://flox.dev/docs/tutorials/ci-cd/?h=ci) for GitHub Actions, CircleCI, and GitLab to pull and activate the same environments locally, in CI and in prod. 

Or use Flox [containerize](https://flox.dev/docs/reference/command-reference/flox-containerize/?h=containerize) to package your environments as OCI images—fully pinned and runnable anywhere. 
From bare metal to VMs, from Docker Swarm to Kubernetes to AWS Lambda—the runtime context might change, but Flox environments run and behave the same everywhere.

Need an example? See how [the Flox Docs team uses Flox in CI](https://flox.dev/blog/integrating-flox-with-ci-for-consistent-reproducible-dev-environments/) to build, test and deploy this docs site. 


### __And more...__

- Create a reusable toolchain or templates to bootstrap new projects by [reusing and combining dev environments](https://flox.dev/docs/tutorials/composition/).

- Create a portable [environment with transparent auth](https://flox.dev/blog/get-your-preferred-secrets-manager-in-a-portable-cross-platform-cli-toolkit/) via a third-party secrets manager so cross-platform workflows work the same everywhere: locally, in CI, or in production.


[install_flox]: ./install-flox.md
[flox_5_minutes]: ./flox-5-minutes.md
[create_guide]: ./tutorials/creating-environments.md
[share_guide]: ./tutorials/sharing-environments.md
[init]: ./reference/command-reference/flox-init.md
[search]: ./reference/command-reference/flox-search.md
[show]: ./reference/command-reference/flox-show.md
[catalog]: ./concepts/packages-and-catalog.md
[install]: ./reference/command-reference/flox-install.md
[activate]: ./reference/command-reference/flox-activate.md
[edit]: ./reference/command-reference/flox-edit.md
[push]: ./reference/command-reference/flox-push.md
[pull]: ./reference/command-reference/flox-pull.md
[delete]: ./reference/command-reference/flox-delete.md
[list]: ./reference/command-reference/flox-list.md
[manifest]: ./reference/command-reference/manifest.toml.md
[rust-cookbook]: ./cookbook/languages/rust.md
[multi-arch]: ./tutorials/multi-arch-environments.md
[config]: ./reference/command-reference/flox-config.md
[services]: ./concepts/services.md
[floxhub_packages]: https://hub.flox.dev/packages
