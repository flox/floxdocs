# Telemetry

We collect telemetry to understand how people use Flox so we can improve its features and functions.

Telemetry collection is opt-in by default, but you can easily opt out.

This document describes the specific telemetry metadata collected by Flox, where it is stored in the local context, and how it is sent to Flox’s servers. It also explains how you can disable telemetry completely—i.e., on a _system-wide_ basis—or selectively disable it for _specific users_ and/or _Flox environments_.


## 1. Does Flox collect personal data?

No. Flox does not collect personal data.

If telemetry collection is not disabled, Flox generates an anonymized [Version 4 (random) UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)) the first time a user invokes the `flox init` subcommand to create an environment. This UUID is stored at `$HOME/.local/share/flox/metrics-uuid`. On multi-user systems, Flox generates Version 4 (random) UUIDs for each user, stored in the same path. Section 2, below, describes the content of Flox telemetry records.

[[NOTE: We have two UUIDs in `~/.local/share/flox/`. It behooves us to explain what each is for, doesn't it? The `metrics-uuid` is the one that's incorporated into the telemetry we send. Is `uuid` for FloxHub?]]

## 2. What telemetry do we collect?

An individual telemetry record consists of:

-  A specific Flox subcommand;
-  Timestamp data correponding to that subcommand;
-  Relevant information about the system context where Flox is installed.

This section describes each of these in detail.


### Flox-specific subcommands

Flox has approximately two dozen subcommands. These can be invoked using `flox <subcommand>`.

These subcommands are recorded as telemetry each time they are invoked.

If a user types `flox init` to create a new environment, the `init` _subcommand_ is captured as a telemetry record—but _only_ the `init` subcommand. Flox does not record metadata that’s specific to your environment, such as the files it contains or its base path. Below is example telemetry for the `flox init` subcommand:

```
{"subcommand":"install","timestamp":[2024,227,4,54,45,305948829,0,0,0],"uuid":"bd29ca10-8638-4540-a2f6-015456bb5940","flox_version":"1.2.3-24-g927e2624","os_family":"Linux","os_family_release":"6.1.0-21-amd64","os":"debian","os_version":"12","empty_flags":[]}
```

### Timestamp metadata

Second, we record timestamp metadata corresponding to the specific Flox subcommand and its execution:

In the example above, the timestamp metadata consists of a list of comma-separated values, namely: `[2024,227,4,54,45,305948829,0,0,0]`. This breaks down as follows:

-  2024 = year
-  227 = day of the year
-  4 = hour of the day
-  54 = minute of the hour
-  45 = seconds

The large value (`305948829`) is [I HAVE NO CLUE WHAT THIS IS], while `0,0,0` [I HAVE NO CLUE " " "].


### The Flox version and local system context

Finally, we record the specific version of Flox software, along with basic information about where Flox is installed. The code block below contains telemetry from an Intel-based Mac running macOS Sonoma:

```
{"subcommand":"activate","timestamp":[2024,227,2,33,57,610748000,0,0,0],"uuid":"c1a7ce62-590e-41c8-a7ce-cb9ba2d1f97f","flox_version":"1.2.2","os_family":"Mac OS","os_family_release":"23.5.0","os":null,"os_version":null,"empty_flags":[]}
{"subcommand":"list","timestamp":[2024,227,2,34,0,488361000,0,0,0],"uuid":"c1a7ce62-590e-41c8-a7ce-cb9ba2d1f97f","flox_version":"1.2.2","os_family":"Mac OS","os_family_release":"23.5.0","os":null,"os_version":null,"empty_flags":[]}
{"subcommand":"edit","timestamp":[2024,227,2,34,7,707653000,0,0,0],"uuid":"c1a7ce62-590e-41c8-a7ce-cb9ba2d1f97f","flox_version":"1.2.2","os_family":"Mac OS","os_family_release":"23.5.0","os":null,"os_version":null,"empty_flags":[]}
{"subcommand":"pull","timestamp":[2024,227,2,34,46,491307000,0,0,0],"uuid":"c1a7ce62-590e-41c8-a7ce-cb9ba2d1f97f","flox_version":"1.2.2","os_family":"Mac OS","os_family_release":"23.5.0","os":null,"os_version":null,"empty_flags":[]}
```

This file uses [JSONL (JSON Lines)](https://jsonlines.org/) to record telemetry metadata.

Each JSONL is a discrete JSON object consisting of (**1**) a specific Flox subcommand, (**2**) details about the Flox software version, and (**3**) the UUID of the user. It also records (**4**) details about the operating system platform (MacOS) and (**5**) its kernel (Darwin version 23.5.0).

On Linux systems, the telemetry Flox emits typically includes (**6**) information about the name/release of the Linux distribution. In the JSONL record below, this is captured as `"os":"debian","os_version":12` — i.e., a Debian Linux system running "Bookworm", the latest Debian release.

```
{"subcommand":"install","timestamp":[2024,227,2,8,38,103541001,0,0,0],"uuid":"f52941c5-50eb-4857-933a-75d6778e145a","flox_version":"1.2.3-20-g13aa3aae","os_family":"Linux","os_family_release":"6.10.3-amd64","os":"debian","os_version":12,"empty_flags":[]}
```


## 3. Where does Flox cache telemetry?

Telemetry metadata is stored on your local system and periodically replicated to Flox’s servers.

Each user’s telemetry file is cached in the path`$HOME/.cache/flox/metrics-events-v2.json`. It consists solely of the JSONL objects and metadata records described in Section 2, above.

This file is purged each time Flox replicates telemetry. It does not accrete in size.


## 4. How does Flox send telemetry?

I HAVE NO [CENSORED] IDEA. HELP ME BACKFILL THIS AND I'LL HAPPILY FLESH IT OUT!


## 5. Enabling or Disabling Telemetry

You can selectively enable or disable telemetry based on your preferences or requirements.


### System-wide settings

To disable telemetry on a system-wide basis, just add the following line to `flox.toml` in `/etc`.

```
disable_metrics = true
```

You can do this using your preferred editor, or programmatically.

```
echo 'disable_metrics = true' | sudo tee -a /etc/flox.toml
```

To revert this change, delete or comment out this line.


### Per-user settings

If you just want to disable telemetry for yourself, you can use the `flox config` subcommand.

From your terminal or tty, type:

```
flox config --set-bool disable_metrics true
```

Alternately, you can add the line `disable_metrics = true` to `flox.toml` in `$HOME/.config/flox/`.

You will need to create this file if it does not already exist. This method is useful when you’re managing Flox on multi-user systems; configuring it for a team; or integrating it into CI pipelines, where the runtime environment needs to be clearly defined and version-controlled. Here’s a one-liner that does this:

```
mkdir -p "$HOME/.config/flox" && { [ -f "$HOME/.config/flox/flox.toml" ] || touch "$HOME/.config/flox/flox.toml"; } && echo 'disable_metrics = true' >> "$HOME/.config/flox/flox.toml"
```

To revert this change, comment out this line and/or delete the `flox.toml` file.


### Per-environment settings

Finally, you can disable telemetry on a per-environment basis by setting an environment variable.

To do this, add the following to the `[vars]` section in your Flox environment’s [`manifest.toml`](https://flox.dev/docs/reference/command-reference/manifest.toml/).

```
[vars]
FLOX_DISABLE_METRICS=true
```
You can find this file in the path `.flox/env/` in your environment’s project folder. You can edit `manifest.toml` using either your preferred editor or by using the [`flox edit` subcommand](https://flox.dev/docs/reference/command-reference/flox-edit/?h=).

To change this setting simply remove or comment-out the variable.