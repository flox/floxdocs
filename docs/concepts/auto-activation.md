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

Flox provides three commands for shell integration:

- **In-place activation** (`eval "$(flox activate ...)"` in Bash/Zsh,
  or equivalent in other shells) — Activates an environment in the
  current shell _and_ installs the auto-activation hook. You can target
  any environment with `-D` (default), `-d` (directory), or `-r`
  (remote). If no environment exists, the command fails with an error.
- **Subshell activation** (`flox activate`) — Activates an environment
  in a subshell without installing the auto-activation hook.
- **Hook only** (`eval "$(flox hook)"` in Bash/Zsh, or equivalent in
  other shells) — Installs the auto-activation hook _without_ activating
  any environment. Use this if you want auto-activation but don't have a
  default environment.

| Command | Activates environment | Installs hook |
|---|---|---|
| `eval "$(flox activate -D)"` | Yes (default env) | Yes |
| `eval "$(flox activate -d .)"` | Yes (directory env) | Yes |
| `eval "$(flox activate -r <owner>/<env>)"` | Yes (remote env) | Yes |
| `flox activate` | Yes | No |
| `eval "$(flox hook)"` | No | Yes |

=== "Bash"

    Add the following line to the end of your `~/.bashrc`:

    ```{ .bash .copy }
    eval "$(flox activate -D)"
    ```

=== "Zsh"

    Add the following line to the end of your `~/.zshrc`:

    ```{ .zsh .copy }
    eval "$(flox activate -D)"
    ```

=== "Fish"

    Add the following line to the end of your `~/.config/fish/config.fish`:

    ```{ .fish .copy }
    flox activate -D | source
    ```

=== "Tcsh"

    Add the following line to the end of your `~/.tcshrc`:

    ```{ .tcsh .copy }
    eval "`flox activate -D`"
    ```

!!! note

    Any in-place `flox activate` invocation installs the hook — not just
    `-D`. For example, if you already have
    `eval "$(flox activate -r owner/default)"` in your shell RC file,
    you don't need to change it.
    See the
    [default environment tutorial](../tutorials/default-environment.md)
    for more details.

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

## How it works

Once the shell hook is installed, it runs on every prompt
(or directory change, depending on your shell).
Here is what happens on each prompt:

1. **Discovery** — The hook walks the directory tree from your current
   working directory up to the filesystem root,
   collecting all directories that contain a `.flox/` subdirectory.
2. **Eligibility check** — Each discovered environment is checked to see
   whether auto-activation has been **allowed** for it (see
   [Allowing and denying auto-activation](#allowing-and-denying-auto-activation)
   below). Only allowed environments proceed.
3. **Activation** — Eligible environments are activated outermost-first.
   Environment variables are set and hooks run.
   Services are **not** started by default.
   To have services start automatically, set
   [`services.auto-start = true`](../man/manifest.toml.md#options)
   in the manifest.
4. **Deactivation** — When you leave a directory, its environment is
   deactivated and its changes to the shell are reverted.

Most prompts trigger the **fast path**: the hook detects that nothing has
changed (same directory, same environments, same manifest timestamps) and
exits immediately with no output or delay.

## Allowing and denying auto-activation

An environment will not auto-activate unless you have explicitly
**allowed** it. This prevents unexpected code execution when you `cd`
into a directory containing an unfamiliar `.flox/` directory.

!!! warning

    Before allowing auto-activation for an environment, review its
    manifest to understand what hooks and scripts it will run.
    This is especially important for environments obtained from
    untrusted sources (e.g. cloned repositories).

### Interactive prompt

When the hook discovers an environment that has not been registered
(neither allowed nor denied), it prompts in interactive shells:

```text
Auto-activate environment in /path/to/project? [y/N]
```

Answering **y** allows auto-activation for that environment.
Answering **N** (or pressing Enter) skips it for the current session.

### CLI commands

Use [`flox allow`](../man/flox-allow.md) to allow auto-activation for
an environment:

```{ .bash .copy }
flox allow
```

Use [`flox deny`](../man/flox-deny.md) to deny auto-activation:

```{ .bash .copy }
flox deny
```

A single preference record is stored per environment — the latest
decision overwrites any previous one. Preferences are stored in
`$XDG_STATE_HOME/flox/auto-activation.toml`
(default `~/.local/state/flox/auto-activation.toml`).

### How auto-activation preference works

- **Not content-sensitive.** Auto-activation preference is tied to the
  environment's identity, not its manifest content. Once allowed, an
  environment stays allowed regardless of manifest changes.

- **`flox init` does not auto-allow.** Creating a new environment does
  not automatically allow auto-activation for it. You must explicitly
  allow it via `flox allow` or by answering **y** at the interactive
  prompt.

### Global configuration

The `auto_activate` configuration key controls the global behavior:

```{ .bash .copy }
flox config --set auto_activate "<value>"
```

| Value | Behavior |
|---|---|
| `"never"` (default) | Disable auto-activation entirely; the shell hook is not installed |
| `"prompt"` | Prompt interactively for unregistered environments |

!!! note

    The initial release ships with `"never"` as the default so that
    early adopters can opt in explicitly. The default may change to
    `"prompt"` in a future release. When `auto_activate` is `"never"`,
    in-place `flox activate` only activates the specified environment
    without installing the shell hook.

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
    opt-in via `flox allow` like any other environment. Directory
    ownership alone does not grant or deny auto-activation.

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

If you leave the directory and return later,
the suppression is lifted and the environment auto-activates again.

Calling `flox deactivate` multiple times peels off additional layers, one at a time.
You can also specify a list of environments to deactivate (`flox deactivate foo bar bar`), but these must be the innermost environments.

!!! note

    For subshell activations, `exit` still works to leave the subshell,
    but `flox deactivate` is the recommended approach for consistency.

## Interaction with manual activation

Environments activated in a **subshell** — via `flox activate`,
`flox activate -d <path>`, or `flox activate -r <owner>/<name>` without
in-place mode — are managed alongside any other discovered environments.
Any newly activated environment becomes the innermost activation, and
must be deactivated before any other environment, regardless of how
they were activated.

## Comparison with manual activation

Auto-activation and `flox activate` share the same core behavior
(packages, environment variables, hooks) but differ in several ways:

| Behavior | `flox activate` (manual) | Auto-activation |
|----------|--------------------------|-----------------|
| **Trigger** | Explicit `flox activate` command | Automatic on `cd` into `.flox` directory |
| **Mode** | `flox activate -m` or `options.activate.mode` (manifest setting) | `options.activate.mode` (manifest setting) |
| **Gate** | None — user explicitly chose to activate | Requires auto-activation to be allowed |
| **Deactivation** | `flox deactivate` or `exit` (subshell) | `flox deactivate` |
| **Error handling** | Activation aborts on failure | Individual activations abort on failure, but other layered activations continue |
