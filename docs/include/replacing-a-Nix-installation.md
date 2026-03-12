<!-- markdownlint-disable-file MD041 -->
Flox will reconfigure an existing Nix installation. These changes are designed to improve the overall user experience and make the Nix installation more reliable and easier to support, but it's worth noting that **anyone wishing to revert to a "vanilla" Nix installation after installing Flox will need to re-install Nix**.

<!-- markdownlint-disable-next-line MD051 -->
If you want retain full control of your Nix installation, see the [Nix (Generic)](#nix-generic) instructions.

---

When installing over a previous installation of Nix the Flox installation
will:

1. Back out customizations made to the following files when Nix was
    installed:
    * `/etc/bashrc`
    * `/etc/bash.bashrc`
    * `/etc/profile.d/nix.sh`
    * `/etc/zshrc`
    * `/etc/zsh/zshrc`
1. Overwrite the system-wide `/etc/nix/nix.conf`
1. (If applicable) convert the Nix installation to a multi-user install
1. Reconfigure the `nix-daemon` invocation

If you are installing over a previous installation of Nix we suggest that you install Flox to a test machine or VM to gain familiarity with it first.

The version of Nix installed by Flox tracks the stable version of Nix in nixpkgs, occasionally adding additional backports or patches.
Nix is usually updated monthly, although if Nix makes breaking changes, updates may be less frequent.
