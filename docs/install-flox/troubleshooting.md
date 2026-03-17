---
title: Troubleshooting installation
description: How to diagnose and fix common Flox installation issues
---

<!-- markdownlint-disable-file MD024 -->

# Troubleshooting installation

If you run into problems installing Flox,
this page will help you diagnose what went wrong and find a solution.

## Finding install logs

The first step in debugging a failed installation is to find the install logs.
The location depends on your operating system.

### macOS

The macOS system installer logs to `/var/log/install.log`.
To watch log output in real time while running the Flox installer,
open a separate terminal window and run:

```{ .sh .code-command .copy }
tail -f /var/log/install.log
```

Then start the Flox installation in another window.
The log will show detailed output from each phase of the installation,
including any errors in pre-install or post-install scripts.

!!! tip
    The install log can be thousands of lines long.
    Search for `error`, `fail`, or `flox` to find relevant entries.

### Linux

On Linux the Flox installer writes a log file to `/tmp` with a timestamped
filename:

```text
/tmp/flox-installation.log.<timestamp>
```

For example:

```text
/tmp/flox-installation.log.1773188428
```

List matching files to find it:

```{ .sh .code-command .copy }
ls -al /tmp/flox-installation.log.*
```

## Previous Nix installation

The most common cause of a failed Flox installation is
a previous Nix installation on the system.
In some cases the Flox installer may report success
but fail to actually install the `flox` binary.

### Symptoms

- The installer completes without errors,
  but `flox --version` returns "command not found."
- The post-install script exits early because it detects an existing Nix
  configuration.

### Diagnosis

Check whether a previous Nix installation is present:

```{ .sh .code-command .copy }
ls -la /nix/var/nix/db/db.sqlite
```

```{ .sh .code-command .copy }
cat /etc/nix/nix.conf
```

If either of these exist and were not created by Flox,
a previous Nix installation is likely interfering.

### Solution: remove the previous Nix installation

You will need to remove the previous Nix installation before installing Flox.

=== "Determinate Nix Installer"

    If Nix was installed with the
    [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer),
    run:

    ```{ .sh .code-command .copy }
    /nix/nix-installer uninstall
    ```

    Then re-run the Flox installer.

=== "Other Nix installations"

    For Nix installations that were not made with the Determinate Nix Installer,
    follow the
    [official Nix uninstall instructions](https://nix.dev/manual/nix/stable/installation/uninstall)
    for your platform.

    Then re-run the Flox installer.

!!! info
    The Flox installer performs some opinionated configuration of Nix.
    See the "Replacing an existing Nix installation" section on the
    [Install](install.md) page for details on what changes are made.

## Orphaned Nix build users (macOS)

On macOS, a previous Nix installation may have created system users
named `_nixbld1` through `_nixbld32`.
If these users were not fully removed during uninstallation,
the Flox installer's post-install script can fail because it expects to create
these users with specific UIDs.

This is particularly common with Nix installations that are two or more years old
(prior to macOS 15).
See [NixOS/nix#10892](https://github.com/NixOS/nix/issues/10892) for background.

### Symptoms

The install log (`/var/log/install.log`) contains an error like:

```text
It seems the build user _nixbld8 already exists, but with the UID '308'.
```

### Solution

Remove the orphaned build users and then re-install Flox.

1. Delete the orphaned build users:

    ```{ .sh .code-command .copy }
    for i in $(seq 1 32); do sudo dscl . -delete /Users/_nixbld$i 2>/dev/null; done
    ```

2. If the `/nix` APFS volume is still mounted, remove it:

    ```{ .sh .code-command .copy }
    sudo diskutil apfs deleteVolume /nix
    ```

3. Re-install Flox following the instructions on the [Install](install.md) page.

## Homebrew uninstall did not fully clean up (macOS)

If you previously installed Flox via Homebrew and the uninstallation did not
complete cleanly (for example, the `/nix` volume could not be unmounted),
you may need to force a full cleanup before re-installing.

### Solution

```{ .sh .code-command .copy }
brew uninstall --force --zap flox
```

After rebooting, re-install Flox following the instructions on the
[Install](install.md) page.

## Flox builds from source when installed as a Nix flake input

If you consume Flox as a flake input in your NixOS or nix-darwin configuration,
you may find that Nix builds Flox from source instead of fetching it from the
Flox binary cache.
There are two common causes.

### Using `follows` for nixpkgs

If your flake input for Flox uses `inputs.nixpkgs.follows = "nixpkgs"`,
the resulting store paths will differ from the ones in the Flox binary cache
because the cache was built against the nixpkgs revision pinned in the
[Flox flake.lock](https://github.com/flox/flox).

#### Solution

Remove the `follows` directive so that Flox uses its own pinned nixpkgs:

```nix
# flake.nix
{
  inputs = {
    flox.url = "github:flox/flox";
    # Do NOT add: flox.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

The trade-off is an extra copy of nixpkgs in your Nix store,
but Flox's dependencies and yours will coexist without collisions.

### Flox binary cache not in `substituters`

Even with the correct Nix configuration files,
the Flox binary cache (`cache.flox.dev`) may appear only in
`trusted-substituters` and not in `substituters`.
Nix only queries caches listed in `substituters` (or `extra-substituters`)
during builds.
The `trusted-substituters` setting only controls which caches
non-root users are *permitted* to add via `extra-substituters` —
it does not cause Nix to query those caches on its own.

#### Diagnosis

```{ .sh .code-command .copy }
nix config show | grep substituters
```

If `cache.flox.dev` appears in `trusted-substituters` but **not** in
`substituters`, Nix will never query it and will fall back to building
from source.

#### Solution

Add the Flox cache to `extra-substituters` so that it is merged into
`substituters` and actually queried during builds.
For example, in your NixOS or nix-darwin `nix.settings`:

```nix
nix.settings = {
  extra-substituters = [ "https://cache.flox.dev" ];
  extra-trusted-public-keys = [
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
  ];
};
```

Or directly in `/etc/nix/nix.conf`:

```ini
extra-substituters = https://cache.flox.dev
extra-trusted-public-keys = flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=
```

Verify the change took effect:

```{ .sh .code-command .copy }
nix config show | grep substituters
```

`cache.flox.dev` should now appear in the `substituters` line.

## Reporting issues

If your issue is not covered here,
please report it on [Flox Discourse](https://discourse.flox.dev){:target="_blank"}
with:

- Your operating system and version
- The installation method you used (Pkg, Homebrew, Debian, RPM, etc.)
- The full install log output (see [Finding install logs](#finding-install-logs)
  above)
- Any error messages you encountered
