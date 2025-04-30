---
title: Introduction
description: What is Flox?
hide:
  - toc
---

<!-- shut up linter -->
<!-- markdownlint-disable-file MD033 -->
<!-- markdownlint-disable-file MD009 -->
<!-- markdownlint-disable-file MD022 -->
<!-- markdownlint-disable-file MD030 -->
<!-- markdownlint-disable-file MD012 -->
<!-- markdownlint-disable-file MD032 -->

# What is Flox?

<div class="grid" markdown>

<p>
Flox is a next-generation package manager that is language-agnostic and cross-platform by default. 
<br><br>
-> Install packages into environments without fear of dependency conflicts. 
<br>
-> Activate an environment to get your project running in a new sub-shell. 
<br><br>
There are no containers involved, so there's no isolation preventing you from using your favorite tools and dotfiles. Flox uses Nix under the hood to provide rock-solid reproducibility, ....  
</p>

<iframe width="460" height="260" src="https://www.youtube.com/embed/aidi5svDml8?si=rrgQ6a0oQzdFNgWs" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

</div>

## Get Started
<div class="grid cards" markdown>

-   :octicons-terminal-24:{ .lg .middle } __Quick start with the Flox CLI__

    ---

    Install `flox` with `brew` and get your dev 
    environment set up in minutes.

    [:octicons-arrow-right-24: Download & Install][install_flox]

    [:octicons-arrow-right-24: Flox in 5 minutes][flox_5_minutes]
    
    [:octicons-arrow-right-24: Search packages in FloxHub][floxhub_packages]{:target="_blank"}

-   :material-nix:{ .lg .middle } __Already using Nix? Start here__

    ---

    Flox makes the power of Nix more accessible for your team, and maybe for you too.

    [:octicons-arrow-right-24: Install Flox with flakes or profiles](install-flox.md?h=nix#__tabbed_1_6){:target="_blank"}

    [:octicons-arrow-right-24: Flox brings Nix to your teams](https://flox.dev/blog/its-time-to-bring-nix-to-work/){:target="_blank"}

    [:octicons-arrow-right-24: Use flakes in Flox](https://flox.dev/blog/extending-flox-with-nix-flakes/){:target="_blank"}

</div>

### Examples

Use one tool to set up your dev environment, no matter what language you're working with. 
Combine multiple languages in a single environment or layer environments for more flexibility.

See how to get started with Flox in your language:


[Node :simple-nodedotjs:](https://flox.dev/blog/using-flox-to-create-portable-reproducible-nodejs-environments/){ .md-button }
[Go :fontawesome-brands-golang:](https://flox.dev/blog/using-flox-to-create-portable-reproducible-go-environments/){ .md-button }
[Python :fontawesome-brands-python:](https://flox.dev/blog/using-flox-to-create-portable-reproducible-python-environments/){ .md-button }
[Rust :fontawesome-brands-rust:](https://flox.dev/blog/using-flox-to-create-portable-reproducible-python-environments/){ .md-button }
[Ruby :material-language-ruby:](https://flox.dev/blog/making-ruby-projects-easier-to-share/){ .md-button }



## Why Flox?

The same challenges, no matter the stack: inconsistent environments, dependency drift, and brittle build processes that don’t scale well across machines, teams, or deployment targets. Current solutions often add complexity and fragmentation.

Flox takes a different approach — providing a consistent, language-agnostic workflow for managing environments that just works, from local development to CI to production. 

Use Flox to solve three common use cases: 

- Reproducible dev environments 
- Reliable package management across systems 
- Consistent builds from local to production

## Reproducible dev environments

Set up a [local developer environment](https://flox.dev/docs/tutorials/creating-environments/) that will work the same across multiple system types and architectures. [Activate](https://flox.dev/docs/concepts/activation/) an environment to enter a subshell with the configuration only when you need it. Switch between development environments across multiple language ecosystems using a consistent, unified workflow.

All the [packages](https://hub.flox.dev/packages), [activation scripts](https://flox.dev/blog/mastering-hooks-and-profiles-for-reproducible-flox-environments/), [environment variables](https://flox.dev/docs/tutorials/creating-environments/#customize-the-shell-hook-and-environment-variables) and [services](https://flox.dev/docs/concepts/services/) needed to reproduce the environment are declared in a simple [manifest](https://flox.dev/docs/concepts/manifest/) that can be checked into [version control along with your source code](https://flox.dev/blog/flox-and-teams-managing-your-code-and-your-runtime-environment-in-just-one-place/).

Once your environment is configured, you can simplify the setup instructions in your README to a single command (`flox activate`), making it easy to [share environments](https://flox.dev/blog/flox-and-teams-using-shared-flox-environments/) and [onboard new developers](https://flox.dev/blog/flox-and-teams-onboarding-made-easy-with-github-and-flox/).

Create a reusable toolchain or templates to bootstrap new projects by [reusing and combining dev environments](https://flox.dev/docs/tutorials/composition/).


## Reproducible package management for any system

Use Flox to set up your [default environment](https://flox.dev/docs/tutorials/default-environment/) with a set of 
packages that you always want available, whether you're on macOS or Linux -- x86 or ARM.

Then, when you need to [set up a new laptop](https://flox.dev/blog/setting-up-a-new-laptop-made-easy-with-flox/
), or [keep multiple machines in sync](https://flox.dev/docs/tutorials/sharing-environments/#always-using-the-same-environment-across-multiple-devices
), you can be sure you're using the exact same versions, no matter when or where you need them. 

If you're already using Homebrew, you can easily [migrate or use Homebrew and Flox together](https://flox.dev/docs/tutorials/migrations/homebrew/).



## Consistent builds from local to CI to production

Flox lets you define what an environment _is_ in a way that can be reused across local dev, CI, and production. 
Leverage [pre-built integrations](https://flox.dev/docs/tutorials/ci-cd/?h=ci) for GitHub Actions, CircleCI, and GitLab to pull and activate the same environments locally, in CI and in prod. 

Or use Flox [containerize](https://flox.dev/docs/reference/command-reference/flox-containerize/?h=containerize) to package your environments as OCI images—fully pinned and runnable anywhere. 
From bare metal to VMs, from Docker Swarm to Kubernetes to AWS Lambda—the runtime context might change, but Flox environments run and behave the same everywhere.

Need an example? See how [the Flox Docs team uses Flox in CI](https://flox.dev/blog/integrating-flox-with-ci-for-consistent-reproducible-dev-environments/) to build, test and deploy this docs site. 


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
