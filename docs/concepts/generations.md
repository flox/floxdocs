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

## Switching and viewing generations

Generations offer change management for environments;
it's similar to `git`, but tailored for environments.

Suppose you make an edit to an environment,
but then after activating and using the environment, you want to undo the change
you just made.
To undo the change, you can run `flox generation rollback`.

If you've made a series of edits over time but later realize you want to discard them all,
you can use `flox generation list` to display all the different versions of the environment, and then you can use `flox generation switch <generation number>`
to revert to the version of the environment prior to all the environments.
You can also view generations on FloxHub on the `Generations` tab of an
environment's page.

## History

Rolling back to a previous generation introduces another concept:
history.
Rolling back doesn't create a new generation, but it does add an entry to the environment's history.
Suppose you `flox generation rollback` from generation 18 to 17.
Although the list of generations hasn't changed, the latest entry in the environment's history will now say that generation 17 is the current generation.
Note that although generation 18 is the "latest" in the sense that it has the
highest generation number and was most recently created, it is not the latest to
be current.

This history of what generation is current at a given point in time can be
viewed on FloxHub on the `Change Log` tab for an environment.
Or, to use the CLI to view history, you can run `flox generation history`.
This provides a log of what generation of an environment was current at the time
an environment was activated remotely without being pulled, with
`flox activate -r`.

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
