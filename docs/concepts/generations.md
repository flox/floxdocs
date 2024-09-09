---
title: What is a generation?
description: Everything you need to know about generations.
---

# What is a generation?

Generations refer to a **version number of an environment** on
[FloxHub][floxhub_concept].
Both imperative and declarative commands that modify an environment on
[FloxHub][floxhub_concept] increment the generation number for the environment. 

Read more about creating your first generation in the
[sharing guide][sharing_guide].

## First generation

The first environment generation (1) is created when you use
**[`flox push`][flox_push]** to send an environment to
[FloxHub][floxhub_concept]. 

## New generations

**New generations are created automatically** when you use a CLI command that
modifies the environment,
such as [`flox install`][flox_install] or [`flox edit`][flox_edit].

## Staged local generations

With a [centrally managed environment][environment_guide] **new local
generations are staged automatically**.
Suppose you [`flox pull`][flox_pull] an environment at generation 15 on
[FloxHub][floxhub_concept].
If you now run [`flox install`][flox_install] three times then you will have
generations 16-18 locally.
The next [`flox push`][flox_push] would sync these three new generations to
[FloxHub][floxhub_concept] if you have permission to write to the environment.

## Generation lock

[Centrally managed environments][environment_guide] that are pulled with
[`flox pull`][flox_pull] will store a generation lock which describes
**the current pulled generation**.
This allows this environment to advance to newer generations explicitly on the
next [`flox pull`][flox_pull].

[floxhub_concept]: .//floxhub.md
[flox_push]: ../reference/command-reference/flox-push.md
[flox_install]: ../reference/command-reference/flox-install.md
[flox_edit]: ../reference/command-reference/flox-edit.md
[flox_pull]: ../reference/command-reference/flox-pull.md
[sharing_guide]: ../tutorials/sharing-environments.md
[environment_guide]: ../tutorials/creating-environments.md
