---
title: Signing keys
description: Create and use signing keys to sign built artifacts
---

# Signing keys

In order to upload a package it must be signed, and in order to install a package published to a Flox Catalog you must configure your system to trust the public key used to sign the package.
By default, packages are signed with a key that's included with the Flox installer, so Flox is configured to be able to install user-published packages out of the box.

However, if you're providing your own Catalog Store, then you must

- Create the signing keys
- Distribute the private key to users trusted to publish packages
- Distribute the public key to users allowed to install those packages
- Have those users configure their systems to trust the public key

## Create a signing key pair

Use the `nix` CLI to generate a private key:

```sh
$ nix key generate-secret --key-name signing-key > signing-key.key
```

Then generate a public key from the private key:

```sh
$ nix key convert-secret-to-public < signing-key.key > signing-key-pub.key
```

## Sign packages to upload artifacts

Once you've generated the key, you can configure Flox to sign the packages
you publish with that (private) key:

!!! warning "The path to the private key must configured with an absolute path for security purposes."

```sh
flox config --set publish.signing_private_key "/path/to/signing-key.key"
```

If you need to use a different signing key (for example, to publish to a different catalog), you can use the `--signing-key` option with the `flox publish` command.
The private key is necessary for uploading artifacts, so anyone that needs that capability will need access to the key.
One solution is to put the key in a password manager and grant access to users that need to publish.

## Trust a public key to install published artifacts

In order to install a published package you must configure your system to trust the corresponding public key that the artifact was signed with.
This amounts to adding the public key to the list of `extra-trusted-public-keys` in your Nix configuration.

### Add a new trusted key

#### Nix installed via Flox, or standalone Nix installation

If you installed Nix as part of your Flox installation, you need to edit your `/etc/nix/nix.conf` to add a new entry to the `extra-trusted-public-keys` option.
If `/etc/nix/nix.conf` doesn't exist, create it.
If the `extra-trusted-public-keys` option doesn't exist, create it.
This option is a space-delimited list of trusted public keys.

Add the following line, where `<key contents>` is the contents of the signing public key file and `<existing keys>` is any keys that were already populated for this option (if it existed):

```text
extra-trusted-public-keys = <existing keys> <key contents>
```

Note that you do not need quotes around keys in the `extra-trusted-public-keys` option.
In order for the newly trusted key to take effect, the Nix daemon needs to be restarted.
On Linux the daemon is managed via `systemd`, so you can restart it with the following command:

```bash
$ sudo systemctl restart nix-daemon
```

On macOS the Nix daemon is managed via `launchd`, so you can restart it with the following command (note that you have to run the command twice, this is not a typo):

```bash
sudo launchctl kickstart -k system/org.nixos.nix-daemon
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

#### NixOS, nix-darwin, or home-manager

For systems whose configuration is managed with Nix, you need to add the public key to the list of trusted public keys in your system configuration.
For NixOS, `nix-darwin`, and `home-manager` the configuration option is the same:

```nix
nix.settings.trusted-public-keys = [
  "<key contents>"
];
```

Once this setting has been edited, rebuild and switch into your new configuration.

### Verify that the key is now trusted

Now verify that the daemon has been restarted and picked up the new key.
You can do this by printing out the daemon's current configuration, and searching for the key that you've just added:

```text
$ nix config show | grep trusted-public-key
```
