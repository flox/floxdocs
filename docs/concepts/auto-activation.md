---
title: Auto-activation
description: How environments activate automatically when you enter a directory
---

# Auto-activation

Flox environments are powerful,
but remembering to run `flox activate` every time you enter a project
directory can be tedious.
**Auto-activation** solves this by automatically activating environments
when you `cd` into a directory containing a `.flox/` directory,
and deactivating them when you leave.

This means your tools, environment variables, hooks, and services are
always ready — no manual activation required.

## Enabling auto-activation

To enable auto-activation, add a single line to your shell's RC file.

!!! note

    If you already have `eval "$(flox activate -r owner/default)"` in
    your shell RC file for your default environment, you don't need to
    change it. Auto-activation hooks are installed automatically
    whenever `flox activate` is used in eval mode, regardless of
    whether `-r` or `-d` flags are specified.
    See the
    [default environment tutorial](../tutorials/default-environment.md)
    for more details.

**With a default environment** — use `eval "$(flox activate)"` to
activate your default environment _and_ install the auto-activation hook:

=== "Bash"

    Add the following line to the end of your `~/.bashrc`:

    ```{ .bash .copy }
    eval "$(flox activate)"
    ```

=== "Zsh"

    Add the following line to the end of your `~/.zshrc`:

    ```{ .zsh .copy }
    eval "$(flox activate)"
    ```

=== "Fish"

    Add the following line to the end of your `~/.config/fish/config.fish`:

    ```{ .fish .copy }
    flox activate | source
    ```

=== "Tcsh"

    Add the following line to the end of your `~/.tcshrc`:

    ```{ .tcsh .copy }
    eval "`flox activate`"
    ```

**Without a default environment** — use `eval "$(flox hook)"` to install
the auto-activation hook without activating any environment:

=== "Bash"

    Add the following line to the end of your `~/.bashrc`:

    ```{ .bash .copy }
    eval "$(flox hook)"
    ```

=== "Zsh"

    Add the following line to the end of your `~/.zshrc`:

    ```{ .zsh .copy }
    eval "$(flox hook)"
    ```

=== "Fish"

    Add the following line to the end of your `~/.config/fish/config.fish`:

    ```{ .fish .copy }
    flox hook | source
    ```

=== "Tcsh"

    Add the following line to the end of your `~/.tcshrc`:

    ```{ .tcsh .copy }
    eval "`flox hook`"
    ```

Flox provides three commands for shell integration:

| Command | Activates environment | Installs hook |
|---|---|---|
| `eval "$(flox activate)"` | Yes (fails if no env) | Yes |
| `flox activate` | Yes | No |
| `eval "$(flox hook)"` | No | Yes |

- **`eval "$(flox activate)"`** — Activates the environment in the current
  directory _and_ installs the auto-activation hook. This is the recommended
  command for your shell RC file if you have a default environment. If no
  environment exists in the current directory, the command fails with an
  error. The `-d` and `-r` flags can target a specific environment, and the
  hook is always installed regardless of which flags are used.
- **`flox activate`** — Activates an environment (subshell or in-place) without
  installing the auto-activation hook.
- **`eval "$(flox hook)"`** — Installs the auto-activation hook _without_
  activating any environment. Use this if you want auto-activation but don't
  have a default environment.

## How it works

Once the shell hook is installed, it runs on every prompt
(or directory change, depending on your shell).
Here is what happens on each prompt:

1. **Discovery** — The hook walks the directory tree from your current
   working directory up to the filesystem root,
   collecting all directories that contain a `.flox/` subdirectory.
2. **Eligibility check** — Each discovered environment is checked for two
   conditions: (a) the environment must be **trusted** (security gate),
   and (b) auto-activation must be **enabled** for it (preference gate).
   Only environments that satisfy both conditions proceed.
3. **Activation** — Eligible environments are activated outermost-first.
   Environment variables are set and hooks run.
   Services are **not** started by default.
   To have services start automatically, set
   [`options.services.auto-start = true`](../man/manifest.toml.md#options)
   in the manifest.
4. **Deactivation** — When you leave a directory, its environment is
   deactivated and its changes to the shell are reverted.

Most prompts trigger the **fast path**: the hook detects that nothing has
changed (same directory, same environments, same manifest timestamps) and
exits immediately with no output or delay.

## Trust and security

Auto-activation involves two separate gates that must both be satisfied
before an environment will auto-activate: **security trust** and
**auto-activation preference**.

### Security trust

Environments can run arbitrary code via their `[hook]` and `[profile]`
scripts.
Trust gates whether this code is allowed to execute.

!!! warning

    Before trusting an environment, review its manifest to understand what
    hooks and scripts it will run.
    This is especially important for environments obtained from untrusted
    sources (e.g. cloned repositories).

- **Remote environments** — Trust is managed via the existing
  [`flox activate -t`](../man/flox-activate.md) flag and the
  `trusted_environments` configuration key
  (e.g. `flox config --set trusted_environments."owner/name" trust`).
  Trust is **content-sensitive**: the trust hash includes both the
  environment's identity and the content of its manifest. If the manifest
  changes (e.g. after `git pull`), trust is automatically revoked and you
  must re-trust the environment.

- **Local environments** — Trust is implicit in the act of enabling
  auto-activation. When you run `flox enable` for a local environment,
  that explicit action implies you have reviewed and trust the environment's
  code. There is no separate trust step for local environments.

### Auto-activation preference

Even if an environment is trusted, it will not auto-activate unless you
have explicitly **enabled** auto-activation for it. This is a separate
preference gate that controls whether the hook should activate the
environment when you enter its directory.

#### Interactive prompt

When the hook discovers an environment that has not been registered
(neither enabled nor disabled), it prompts in interactive shells:

```text
Auto-activate environment in /path/to/project? [y/N]
```

Answering **y** enables auto-activation for that environment.
Answering **N** (or pressing Enter) skips it for the current session.

#### CLI commands

Use [`flox enable`](../man/flox-enable.md) to enable auto-activation for
an environment:

```{ .bash .copy }
flox enable
```

Use [`flox disable`](../man/flox-disable.md) to disable auto-activation:

```{ .bash .copy }
flox disable
```

A single preference record is stored per environment — the latest decision
overwrites any previous one.

#### How auto-activation preference works

- **Not content-sensitive.** Unlike security trust, auto-activation
  preference is not tied to manifest content. Once enabled, an environment
  stays enabled regardless of manifest changes. If the trust mechanism
  revokes trust due to content changes, that gates activation separately.

- **`flox init` does not auto-enable.** Creating a new environment does
  not automatically enable auto-activation for it. You must explicitly
  enable it via `flox enable` or by answering **y** at the interactive
  prompt.

- **Preferences are stored** in `$XDG_STATE_HOME/flox/` (default
  `~/.local/state/flox/`), mirroring where trust preferences are stored.

#### Global configuration

The `auto_activate` configuration key controls the default behavior for
unregistered environments:

```{ .bash .copy }
flox config --set auto_activate "<value>"
```

| Value | Behavior |
|---|---|
| `"prompt"` (default) | Prompt interactively for unregistered environments |
| `"always"` | Auto-activate all trusted environments without prompting (opt-out model) |
| `"never"` | Disable auto-activation entirely, even for explicitly enabled environments |

This supports a phased rollout: Flox ships with `"prompt"` (opt-in) and
may later change the default to `"always"` (opt-out).

## Nested environments

When multiple `.flox` directories exist in your directory's ancestor
chain,
all eligible environments are activated simultaneously.
Environments are activated outermost-first,
so an environment in `/home/user/projects` activates before one in
`/home/user/projects/myapp`.

The shell prompt reflects all active environments:

```text
flox [projects myapp] $
```

Use `flox deactivate` to peel off layers one at a time,
starting with the innermost (closest to CWD).

!!! note

    Environments in directories owned by other users require explicit
    opt-in via `flox enable` like any other environment. Directory
    ownership alone does not grant or deny trust.

## Deactivation

[`flox deactivate`](../man/flox-deactivate.md) is the unified way to leave
any environment, whether it was activated manually or via auto-activation.

`flox deactivate` reverses the effects of the **innermost** environment:

- Reverts environment variables set by that environment.
- Restores the shell prompt.
- **Suppresses** that environment so the hook does not re-activate it
  while you remain in the directory.

Only the innermost (closest to CWD) environment can be deactivated.
Running `flox deactivate` on a non-innermost environment fails with a
helpful error — deactivate the inner layers first.
Environments that were explicitly activated (not auto-activated) are
immune to auto-deactivation by the hook.

If you leave the directory and return later,
the suppression is lifted and the environment auto-activates again.

Calling `flox deactivate` multiple times peels off additional layers,
one at a time.

!!! note

    For subshell activations, `exit` still works to leave the subshell,
    but `flox deactivate` is the recommended approach for consistency.

## Interaction with manual activation

Environments activated in a **subshell** — via `flox activate`,
`flox activate -d <path>`, or `flox activate -r <owner>/<name>` without
`eval` — are excluded from auto-activation management.
The shell hook does not discover, activate, deactivate, or suppress
these environments within the subshell.

When `flox activate` is used in **eval mode** (e.g.
`eval "$(flox activate -d <path>)"`), the activated environment is not
excluded. Instead, the auto-activation hook manages it alongside any
other discovered environments.

## Comparison with manual activation

Auto-activation and `flox activate` share the same core behavior
(packages, environment variables, hooks) but differ in several ways:

| Behavior | `flox activate` (manual) | Auto-activation |
|----------|--------------------------|-----------------|
| **Trigger** | Explicit `flox activate` command | Automatic on `cd` into `.flox` directory |
| **Activation mode** | Configurable via `--mode` (dev/run/build) | Always `dev` mode |
| **Gate** | None — user explicitly chose to activate | Requires security trust + auto-activation enabled |
| **Deactivation** | `flox deactivate` or `exit` (subshell) | `flox deactivate` |
| **Error handling** | Activation aborts on failure | Individual activations abort on failure, but other layered activations continue |

!!! note "Activation mode"

    Auto-activation always uses `dev` mode. The manifest setting
    [`options.activate.mode`](../man/manifest.toml.md#options) controls
    the default activation mode. Auto-activation respects this setting.
    If you need `run` or `build` mode, use
    `flox activate --mode run` explicitly.

## Relationship to the default environment

If you already use a line like this for your default environment:

```{ .bash }
eval "$(flox activate -r <youruser>/default)"
```

You don't need to change it. Since auto-activation hooks are installed
for all eval-mode invocations, this line already enables auto-activation
in addition to activating your default environment.

Alternatively, if you prefer a local-only setup, you can replace it with:

```{ .bash }
eval "$(flox activate)"
```

This installs the auto-activation hook without targeting a specific
remote environment. If you have a `.flox` environment in your home
directory (created with `flox init` or `flox pull`), it will be
auto-activated in every shell — serving a similar purpose to the old
default environment pattern. Note that `eval "$(flox activate)"` does
not fetch environments from FloxHub; it only discovers local `.flox/`
directories.

See the
[default environment tutorial](../tutorials/default-environment.md)
for more details on setting up a default environment.

## Advanced: hook state variables

Auto-activation tracks its state using internal environment variables.
These are implementation details and subject to change,
but are documented here for debugging purposes.

??? note "Internal state variables"

    | Variable | Description |
    |----------|-------------|
    | `_FLOX_HOOK_DIFF` | Compressed record of all environment variable changes (additions, modifications, deletions) applied by auto-activated environments |
    | `_FLOX_HOOK_DIRS` | Colon-separated list of `.flox` directories currently active via auto-activation |
    | `_FLOX_HOOK_WATCHES` | JSON array of watched manifest file paths and their modification times, used to detect changes |
    | `_FLOX_HOOK_SUPPRESSED` | Colon-separated list of directories suppressed by `flox deactivate` |
    | `_FLOX_HOOK_NOTIFIED` | Colon-separated list of directories for which the user has already been prompted about auto-activation preference |
    | `_FLOX_HOOK_CWD` | Last-seen working directory, used for fast-path detection |
    | `_FLOX_HOOK_ACTIVATIONS` | Compressed record of per-environment activation metadata (store paths, cached hook output) |
