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

To enable auto-activation, add a single line to your shell's RC file:

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

When `flox activate` is invoked in-place without targeting a specific
environment (no `-d` or `-r` flag),
it activates the current directory's environment _and_ installs a shell
hook that enables auto-activation for the rest of the session.

!!! note

    If you previously used `eval "$(flox activate -r owner/default)"` to
    set up your default environment, the new
    `eval "$(flox activate)"` line replaces it.
    It activates your current directory's environment (if one exists)
    and enables auto-activation everywhere.
    See the
    [default environment tutorial](../tutorials/default-environment.md)
    for more details.

## How it works

Once the shell hook is installed, it runs on every prompt
(or directory change, depending on your shell).
Here is what happens on each prompt:

1. **Discovery** — The hook walks the directory tree from your current
   working directory up to the filesystem root,
   collecting all directories that contain a `.flox/` subdirectory.
2. **Trust check** — Each discovered environment is checked against the
   trust store. Only trusted environments proceed.
3. **Activation** — Trusted environments are activated outermost-first.
   Environment variables are set, hooks run, and services start.
4. **Deactivation** — When you leave a directory, its environment is
   deactivated and its changes to the shell are reverted.
5. **Reattachment** — If you return to a previously activated directory,
   the environment reattaches from cache rather than re-running hooks,
   making it nearly instant.

Most prompts trigger the **fast path**: the hook detects that nothing has
changed (same directory, same environments, same manifest timestamps) and
exits immediately with no output or delay.

## Trust and security

Environments can run arbitrary code via their `[hook]` and `[profile]`
scripts.
Auto-activation means this code runs automatically when you enter a
directory,
so Flox requires you to explicitly trust an environment before it will be
auto-activated.

!!! warning

    Before trusting an environment, review its manifest to understand what
    hooks and scripts it will run.
    This is especially important for environments obtained from untrusted
    sources (e.g. cloned repositories).

### Trusting and denying environments

Use [`flox allow`](../man/flox-allow.md) to trust an environment:

```{ .bash .copy }
flox allow
```

Use [`flox revoke`](../man/flox-revoke.md) to deny auto-activation:

```{ .bash .copy }
flox revoke
```

### How trust works

- **Allow is content-sensitive.** The trust hash includes both the
  environment's absolute path and the content of its manifest.
  If the manifest changes (e.g. after `git pull`), trust is automatically
  revoked and you must run `flox allow` again.

- **Deny is path-only.** The deny hash includes only the environment's
  path, so a denial persists across manifest changes.

- **Deny always wins.** If both allow and deny records exist for an
  environment, it will not be auto-activated.

### Automatic trust

You don't need to manually run `flox allow` for environments you create
or modify through normal Flox commands:

- `flox init` automatically trusts the newly created environment.
- `flox install`, `flox uninstall`, and `flox edit` automatically
  re-trust the environment after modifying the manifest.

Only **out-of-band changes** — such as `git pull`, manual edits, or
another user modifying the manifest — require you to run `flox allow`
again.

## Nested environments

When multiple `.flox` directories exist in your directory's ancestor
chain,
all trusted environments are activated simultaneously.
Environments are activated outermost-first,
so an environment in `/home/user/projects` activates before one in
`/home/user/projects/myapp`.

The shell prompt reflects all active environments:

```text
flox [projects myapp] $
```

Use `flox deactivate` to peel off layers one at a time,
starting with the innermost (closest to CWD).

## Deactivation

[`flox deactivate`](../man/flox-deactivate.md) reverses the effects of
the innermost auto-activated environment:

- Reverts environment variables set by that environment.
- Restores the shell prompt.
- **Suppresses** that environment so the hook does not re-activate it
  while you remain in the directory.

If you leave the directory and return later,
the suppression is lifted and the environment auto-activates again.

Calling `flox deactivate` multiple times peels off additional layers,
one at a time.

## Interaction with manual activation

Environments activated manually — via `flox activate -d <path>` or
`flox activate -r <owner>/<name>` — are excluded from auto-activation
management.
The shell hook does not discover, activate, deactivate, or suppress
manually activated environments.

## Relationship to the default environment

Previously, setting up a default environment required a line like:

```{ .bash }
eval "$(flox activate -r <youruser>/default)"
```

With auto-activation, the simplified setup is:

```{ .bash }
eval "$(flox activate)"
```

This single line both activates the current directory's environment (if
one exists) and installs the auto-activation hook.
If you have a `.flox` environment in your home directory,
it will be auto-activated in every shell — serving the same purpose as
the old default environment pattern.

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
    | `_FLOX_HOOK_NOTIFIED` | Colon-separated list of directories for which the user has already been warned about trust |
    | `_FLOX_HOOK_CWD` | Last-seen working directory, used for fast-path detection |
    | `_FLOX_HOOK_ACTIVATIONS` | Compressed record of per-environment activation metadata (store paths, cached hook output) |
