---
title: Installing Flox from its repository on Debian and Red Hat
description: >
  Add the Flox repository to Debian- or Red Hat-based Linux systems
  for scripted installs and automatic updates.
---

# Installing Flox from its repository on Debian and Red Hat

This document describes a practical method for installing Flox
from its repositories.
Depending on your requirements,
this approach may make it easier to create and manage scripts
to install Flox on local systems or build it into containers.
In addition,
systems configured using this method will receive Flox updates
as they are released.

!!! note
    When you [download and install a Flox `.deb` or `.rpm` package][install_flox],
    the installer performs these steps for you.
    But you can easily script the steps below to automate this process.

These instructions cover the process of installing from Flox's repository
on modern Debian- and Red Hat-based Linux distributions,
such as Ubuntu and Linux Mint (Debian),
or Fedora, RHEL, and Rocky Linux (Red Hat).
They also include an alternate method for installing Flox on Linux systems,
such as older versions of CentOS,
where `yum` is the default package manager.

## Installation overview

Adding Flox's repository to a Debian- or Red Hat-based Linux system's
sources involves the following steps:

- Importing Flox's GPG keys to verify authenticity;
- Configuring the system's package manager to recognize Flox's repository;
  and
- Installing Flox.

### Debian-based systems

To perform these steps on a Debian-based distribution using `apt`,
do the following.

First, download Flox's GPG keyring to `/usr/share/keyrings/`.

``` { .bash .copy }
wget -qO - https://downloads.flox.dev/by-env/stable/deb/flox-archive-keyring.gpg | sudo tee /usr/share/keyrings/flox-archive-keyring.gpg >/dev/null
```

Next, add the Flox repository to `/etc/apt/sources.list.d/flox.list`,
pinning it to the keyring you just downloaded.

``` { .bash .copy }
echo "deb [signed-by=/usr/share/keyrings/flox-archive-keyring.gpg] https://downloads.flox.dev/by-env/stable/deb/ stable/" | sudo tee /etc/apt/sources.list.d/flox.list >/dev/null
```

Finally, update and install Flox.

``` { .bash .copy }
sudo apt update && sudo apt install flox -y
```

!!! note
    These instructions use the modern `signed-by` method,
    which binds the GPG key to only the Flox repository.
    If you are running an end-of-life release
    (Debian 9 or earlier, Ubuntu 18.04 or earlier)
    that does not support `signed-by`,
    see the [Debian SecureApt wiki][debian_secure_apt]
    for the legacy `trusted.gpg.d` approach.

### Red Hat-based systems

To perform these steps on modern Red Hat-based distributions
that use `dnf`, do the following.

First, download Flox's GPG keyring.

``` { .bash .copy }
sudo rpm --import https://downloads.flox.dev/by-env/stable/rpm/flox-archive-keyring.asc
```

Next, add Flox's repository to `/etc/yum.repos.d/flox.repo`.

``` { .bash .copy }
sudo dnf config-manager --add-repo https://downloads.flox.dev/by-env/stable/rpm
```

Finally, install Flox.

``` { .bash .copy }
sudo dnf install flox
```

## Installing from Flox's repository using yum

In CentOS 8 and later,
as with Fedora, RHEL, Rocky Linux, and other modern Red Hat-based systems,
`dnf` is the default package manager.
However, CentOS 7 and earlier ship with `yum` as the default,
and `dnf` is not available.
Since `dnf` is not available on those systems,
the method described above won't work.

This section describes an alternative method
for installing from Flox's repository using `rpm` and `yum`.

!!! note
    Even though the method outlined here deals specifically
    with older versions of CentOS,
    it should also work on any Red Hat-based distribution
    for which `yum` is the default.

To install Flox from its repository using `yum`, do the following.

First, download and import Flox's GPG key.

``` { .bash .copy }
sudo rpm --import https://downloads.flox.dev/by-env/stable/rpm/flox-archive-keyring.asc
```

Next, configure the Flox repository and install Flox with yum.

``` { .bash .copy }
sudo yum --repofrompath=flox,https://downloads.flox.dev/by-env/stable/rpm install flox
```

## Removing the Flox repository

To remove Flox's repository from a Linux system's sources,
do the following.

### Debian-based systems

By default, the Flox repository's source list is in
`/etc/apt/sources.list.d/flox.list`.
However, you can double-check this by running the following command:

``` { .bash .copy }
grep -r 'flox' /etc/apt/sources.list /etc/apt/sources.list.d/
```

Once you've confirmed the existence and location of this file,
delete it along with the GPG keyring.

``` { .bash .copy }
sudo rm /etc/apt/sources.list.d/flox.list
sudo rm /usr/share/keyrings/flox-archive-keyring.gpg
```

Finally, update your package list.

``` { .bash .copy }
sudo apt update
```

!!! note
    If you originally installed Flox via the `.deb` package
    rather than following these manual steps,
    the repository file may be named `flox.sources`
    (DEB822 format) instead of `flox.list`.
    Use the `grep` command above to verify the actual filename.

### Red Hat-based systems

By default, the Flox repository's source list is in
`/etc/yum.repos.d/flox.repo`.
However, you can double-check this by running the following command:

``` { .bash .copy }
sudo dnf repolist | grep flox
```

Delete the `flox.repo` file from `/etc/yum.repos.d/`.

``` { .bash .copy }
sudo rm /etc/yum.repos.d/flox.repo
```

Finally, clean the `dnf` cache.

``` { .bash .copy }
sudo dnf clean all
```

## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Creating environments][creating_guide]

- :simple-readme:{ .flox-purple .flox-heart } [Sharing environments][sharing_guide]

[install_flox]: ../install-flox/install.md
[creating_guide]: ./creating-environments.md
[sharing_guide]: ./sharing-environments.md
[debian_secure_apt]: https://wiki.debian.org/SecureApt
