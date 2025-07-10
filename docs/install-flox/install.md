---
title: Install Flox
description: How to install or upgrade the Flox CLI
---

# Install Flox { #install-flox }

??? info "Minimum Requirements"

    While the resource requirements for Flox will vary based on the
    software you install, we recommend a minimum of 4Gb of memory and 8Gb of
    storage to install most software.

    Minimum requirements for running installed software is not affected
    by Flox.

??? info "Existing Nix installations"

    Use the Flox installer for your system to allow some opinionated configuration of Nix, or use the "Nix - Generic" instructions for full control of your Nix installation. 

=== "MacOS - Pkg"

    **Download and install the package that matches your machine's architecture.**

    1. Download installer for Macs with

        [Apple Silicon][flox_mac_apple_silicon_install]{:target="_blank" .md-button .md-button--primary}
        [Intel processors][flox_mac_intel_install]{:target="_blank" .md-button .md-button--primary}

    2. Double-click to install the downloaded file
    3. Open a terminal window to continue below

    ??? info "Replacing an existing Nix installation"

        The Flox installer will perform some opinionated configuration of Nix, but Nix will still be usable.    
        If you want full control of your Nix installation, see the instructions for installing Flox in the "Nix - Generic" tab above.

        When installing over a previous installation of Nix the Flox installation
        will:

        1. Back out customizations made to the following files when Nix was
            installed:
            * `/etc/bashrc`
            * `/etc/bash.bashrc`
            * `/etc/profile.d/nix.sh`
            * `/etc/zshrc`
            * `/etc/zsh/zshrc`
        2. Overwrite the system-wide `/etc/nix/nix.conf`
        3. (If applicable) convert the Nix installation to a multi-user install
        4. Reconfigure the `nix-daemon` invocation

        These changes are designed to improve the overall user experience and make the Nix installation more reliable and easier to support, but it's worth noting that **anyone wishing to revert to a "vanilla" Nix installation after installing Flox will need to re-install Nix**.

        If you are installing over a previous installation of Nix we suggest that you install Flox to a test machine or VM to gain familiarity with it first.

    **Verify Flox installation**

    If the following command returns without error then you're ready to get
    started!

    ``` console
    $ flox --version # (1)!
    {{ FLOX_VERSION }}

    ```

    4.  The version you will see might be different.   

    **Upgrades to existing Flox installation**

    Download and install the latest image as described above.

=== "MacOS - Homebrew"

    **Brew install** 
    
    In your terminal run:

    ``` { .text .code-command .copy }
    brew install flox
    ```

    !!! note "Note"
        You may be prompted for a `sudo` password or be asked if your terminal has authorization to modify disk contents.


    ??? info "Replacing an existing Nix installation"

        The Flox installer will perform some opinionated configuration of Nix, but Nix will still be usable.    
        If you want full control of your Nix installation, see the instructions for installing Flox in the "Nix - Generic" tab above.

        When installing over a previous installation of Nix the Flox installation
        will:

        1. Back out customizations made to the following files when Nix was
            installed:
            * `/etc/bashrc`
            * `/etc/bash.bashrc`
            * `/etc/profile.d/nix.sh`
            * `/etc/zshrc`
            * `/etc/zsh/zshrc`
        2. Overwrite the system-wide `/etc/nix/nix.conf`
        3. (If applicable) convert the Nix installation to a multi-user install
        4. Reconfigure the `nix-daemon` invocation

        These changes are designed to improve the overall user experience and make the Nix installation more reliable and easier to support, but it's worth noting that **anyone wishing to revert to a "vanilla" Nix installation after installing Flox will need to re-install Nix**.

        If you are installing over a previous installation of Nix we suggest that you install Flox to a test machine or VM to gain familiarity with it first. 

    **Verify Flox installation**

    If the following command returns without error then you're ready to get
    started!

    ``` console
    $ flox --version # (1)!
    {{ FLOX_VERSION }}

    ```

    1.  The version you will see might be different.

    **Upgrade existing Flox installation**

    ``` { .text .code-command .copy }
    brew upgrade flox
    ```

=== "Debian"

    For use on Debian, Ubuntu, and other Debian-based distributions.

    **Download and install the package**

    !!! note "Note"
        The package will register a new source in `/etc/apt/sources.list.d` to enable upgrades via `apt`.

    1. Download flox.deb for your system architecture:

         [64-bit Intel/AMD][flox_x86_64_deb_install]{:target="_blank" .md-button .md-button--primary}
         [64-bit ARM][flox_aarch64_deb_install]{:target="_blank" .md-button .md-button--primary}

    1. Install the downloaded file

        ``` { .text .code-command .copy }
        sudo dpkg -i /path/to/flox.deb
        ```

    **Verify Flox installation**

    If the following command returns without error then you're ready to get
    started!

    ``` console
    $ flox --version # (1)!
    {{ FLOX_VERSION }}

    ```

    1.  The version you will see might be different.

    **Upgrade existing Flox installation**

    ``` { .text .code-command .copy }
    sudo apt update
    sudo apt --only-upgrade install flox
    ```

=== "RPM"

    For use on RedHat, CentOS, Amazon Linux, and other RPM-based distributions.

    !!! note "Note"
        The rpm will register a package repository in `/etc/yum.repos.d` to enable upgrades.
        via `yum`, `dnf` and other compatible tools.

    **Download and install the package**

    1. Download flox.rpm for your system architecture:

         [64-bit Intel/AMD][flox_x86_64_rpm_install]{:target="_blank" .md-button .md-button--primary}
         [64-bit ARM][flox_aarch64_rpm_install]{:target="_blank" .md-button .md-button--primary}

    1. Install the downloaded file

        ``` { .text .code-command .copy }
        sudo rpm --import https://downloads.flox.dev/by-env/stable/rpm/flox-archive-keyring.asc
        sudo rpm -ivh /path/to/flox.rpm
        ```

    ??? info "Replacing an existing Nix installation"

        The Flox installer will perform some opinionated configuration of Nix, but Nix will still be usable.    
        If you want full control of your Nix installation, see the instructions for installing Flox in the "Nix - Generic" tab above.

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

        These changes are designed to improve the overall user experience and make the Nix installation more reliable and easier to support, but it's worth noting that **anyone wishing to revert to a "vanilla" Nix installation after installing Flox will need to re-install Nix**.

        If you are installing over a previous installation of Nix we suggest that you install Flox to a test machine or VM to gain familiarity with it first.

    **Verify Flox installation**

    If the following command returns without error then you're ready to get
    started!

    ``` console
    $ flox --version # (1)!
    {{ FLOX_VERSION }}

    ```

    1.  The version you will see might be different.

    **Upgrade existing Flox installation**

    ``` { .text .code-command .copy }
    sudo yum update flox
    ```

    or

    ``` { .text .code-command .copy }
    sudo dnf update flox
    ```

=== "Nix - Generic"

    **Install Nix**

    Please ensure you are using Nix version `2.18.0` or greater.

    **Install Flox with Nix imperatively**

    * Configure Substituters

        Add the following values to `/etc/nix/nix.conf`, taking care to merge them
        with any `trusted-substituters` or `trusted-public-keys` values that may
        already be defined:

        ``` title="/etc/nix/nix.conf"
        extra-trusted-substituters = https://cache.flox.dev
        extra-trusted-public-keys = {{ FLOX_PUBLIC_KEY }}
        ```

        Then restart the `nix-daemon`, if applicable:

        * Linux:
            ``` { .text .code-command .copy-2 }
            sudo systemctl stop nix-daemon.service
            sudo systemctl restart nix-daemon.socket
            ```
        * MacOS:
            ``` { .text .code-command .copy-2 }
            sudo launchctl kickstart -k -p system/org.nixos.nix-daemon
            ```

    * Install Flox to your _personal_ profile:

        ``` { .text .code-command .copy }
        nix profile install \
              --experimental-features "nix-command flakes" \
              --accept-flake-config \
              'github:flox/flox'
        ```

    * Install Flox to the system-wide `default` profile as root:

        ``` { .text .code-command .copy }
        sudo -H nix profile install \
              --profile /nix/var/nix/profiles/default \
              --experimental-features "nix-command flakes" \
              --accept-flake-config \
              'github:flox/flox'
        ```
    ??? info "On error"

        If you encounter the following error then please upgrade your Nix
        installation (and in particular the running `nix-daemon`) to the latest
        version (minimum supported version is `2.18.0`):

        ```text
        error: builder for '/nix/store/35l1qqyis11y88ic0cp3yxgv3286l4pb-flox-0.0.2-r295.drv' failed with exit code 1;
               last 1 log lines:
               > error: attribute 'requisites' missing
        ```

        If you encounter any other errors with the installer please report the
        bug by way of [discourse][flox_discourse]{:target="_blank"}, including
        a full copy of the command invoked and error encountered.


    **Install Flox with Nix declaratively**

    The following example is for a Nix darwin installation. 
    You may need to modify inputs to match your system.

    ??? info "Using Flox's binary cache"

        Flox hosts a binary cache for its packages, that can be added to your `/etc/nix/nix.conf` file.
        We recommend doing this if you are installing Flox system-wide.

        ``` title="/etc/nix/nix.conf"
        extra-trusted-substituters = https://cache.flox.dev
        extra-trusted-public-keys = {{ FLOX_PUBLIC_KEY }}
        ```

        Or, to your flake configuration by using the `nixConfig` attribute.
        This will ensure that Flox's binary cache is used for all operation within that flake.

        ```title="flake.nix"
        {
            nixConfig = {
                extra-trusted-substituters = ["https://cache.flox.dev"];
                extra-trusted-public-keys = ["flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="];
            };
        }
        ```

        Note that if you don't add either of these options, Flox will be built from source, together with a patched version of Nix.
        Which might take a while on less powerful systems.

    ``` { .text .code-command .copy}
    {
      decription = "Example Darwin system flake";

      nixConfig = {
        extra-trusted-substituters = ["https://cache.flox.dev"];
        extra-trusted-public-keys = ["flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="];
      };

      inputs = {
        nixpkgs = {
          url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
        };
        nix-darwin = {
          url = "github:LnL7/nix-darwin";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        flox = {
          url = "github:flox/flox/v{{ FLOX_VERSION }}";
        };
      };

      outputs = inputs@{ self, nix-darwin, nixpkgs, flox }:
      let
        configuration = { pkgs, ... }: {
          environment.systemPackages =
            [ pkgs.{{ YOUR_PACKAGES }}
              inputs.flox.packages.${pkgs.system}.default
            ];

          nix.settings = {
            experimental-features = "nix-command flakes";
            substituters = [
              "https://cache.flox.dev"
            ];
            trusted-public-keys = [
              "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
            ];
          };

          {{ YOUR_CONFIG }}
        };
      in
      {
        darwinConfigurations."{{ YOUR_HOST }}" = nix-darwin.lib.darwinSystem {
          modules = [ configuration ];
          specialArgs = { inherit inputs; };
        };
      };
    }

    ```

    Run `nix-darwin` to install the configuration and packages you’ve declared. 
    This is an example on `nix-darwin`: `nix run nix-darwin -- switch --flake ~/path/to/flake`

    **Verify Flox installation**

    If the following command returns without error then you're ready to get
    started!

    ``` console
    $ flox --version # (1)!
    {{ FLOX_VERSION }}

    ```

    1.  The version you will see might be different.


    **Upgrade existing Flox installation**    

    If you've installed Flox to the system-wide `default` profile

    ``` { .text .code-command .copy }
    sudo -H nix profile upgrade \
            --profile /nix/var/nix/profiles/default \
            --experimental-features "nix-command flakes" \
            --accept-flake-config \
            '.*flox'
    ```

    Or, if you've installed Flox to your own _personal_ profile

    ``` { .text .code-command .copy }
    nix profile upgrade \
        --experimental-features "nix-command flakes" \
        --accept-flake-config \
        '.*flox'
    ```

    Or, if you've declared Flox using a flake, update the version in the flake

    ``` { .text .code-command .copy }
    ...
        flox = {
            url = "github:flox/flox/v{{ FLOX_VERSION }}";
        };
    ...
    ```

    Nix does not always update transitive dependencies when the version is
    changed,
    so to ensure all updates are applied, run `nix flake update`.

=== "Nix - NixOS"

    **Configure Substituters**

    Similarly configure `/etc/nixos/configuration.nix` to add the lines:

    ``` text title="/etc/nixos/configuration.nix"
    nix.settings.trusted-substituters = [ "https://cache.flox.dev" ];
    nix.settings.trusted-public-keys = [ "{{ FLOX_PUBLIC_KEY }}" ];
    ```

    ... and then invoke:

    ``` { .text .code-command .copy }
    sudo nixos-rebuild switch
    ```

    **Install Flox**

    * Install to your _personal_ profile:

        ``` { .text .code-command .copy }
        nix profile install \
              --experimental-features "nix-command flakes" \
              --accept-flake-config \
              'github:flox/flox'
        ```

    * Install Flox to the system-wide `default` profile as root:

        ``` { .text .code-command .copy }
        sudo -H nix profile install \
              --profile /nix/var/nix/profiles/default \
              --experimental-features "nix-command flakes" \
              --accept-flake-config \
              'github:flox/flox'
        ```

    ??? info "On error"

        If you encounter the following error then please upgrade your Nix
        installation (and in particular the running `nix-daemon`) to the latest
        version (minimum supported version is `2.18.0`):

        ```text
        error: builder for '/nix/store/35l1qqyis11y88ic0cp3yxgv3286l4pb-flox-0.0.2-r295.drv' failed with exit code 1;
               last 1 log lines:
               > error: attribute 'requisites' missing
        ```

        If you encounter any other errors with the installer please report the
        bug by way of [discourse][flox_discourse]{:target="_blank"}, including
        a full copy of the command invoked and error encountered.

    **Verify Flox installation**

    If the following command returns without error then you're ready to get
    started!

    ``` console
    $ flox --version # (1)!
    {{ FLOX_VERSION }}

    ```

    1.  The version you will see might be different.

=== "Container"

    If you have Docker installed then you can also run flox in a container to
    try it out before installing on your system.

    **Invoke Flox container**

    ``` { .text .code-command .copy }
    docker run --pull always --rm -it ghcr.io/flox/flox
    ```

    **Verify Flox installation**

    If the following command returns without error then you're ready to get
    started!

    ``` console
    $ flox --version # (1)!
    {{ FLOX_VERSION }}

    ```

    1.  The version you will see might be different.

=== "WSL 2"

    !!! warning "Support for WSL 2 is experimental."

    !!! info "Install WSL 2"

        Please install and configure **WSL version 2** as described in the
        Microsoft Learn [Install
        WSL](https://learn.microsoft.com/en-us/windows/wsl/install){:target="_blank"}
        guide before installing Flox. Please also [ensure the
        state](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
        (whether the distribution is running or stopped) is running.

        Note that installation will fail on WSL 1.

    Microsoft provides several Linux distributions for use with WSL and will
    use Ubuntu by default. Use the following commands to run and manage your
    chosen distribution:

    * list installed distributions: `wsl --list`
    * run specified distribution: `wsl --distribution <name>`
    * list all available distributions: `wsl --list --online`
    * install distribution: `wsl --install -d <name>`
    * terminate distribution: `wsl --terminate <name>`
    * unregister and delete distribution: `wsl --unregister <name>`

    **Supported distributions**

    Please follow the steps below to install Flox on the distribution of your
    choice:

    ??? example "Ubuntu"

        **Download and install the package**

        1. Download flox.deb for your system architecture:

             [64-bit Intel/AMD][flox_x86_64_deb_install]{:target="_blank" .md-button .md-button--primary}
             [64-bit ARM][flox_aarch64_deb_install]{:target="_blank" .md-button .md-button--primary}

        1. Install the downloaded file

            ``` { .text .code-command .copy }
            sudo dpkg -i /path/to/flox.deb
            ```

    ??? example "Debian"

        **Install prerequisites**

        ``` { .text .code-command .copy }
        sudo apt-get install policycoreutils semodule-utils tar wget xz-utils
        ```

        **Download and install the package**

        1. Download flox.deb for your system architecture:

             [64-bit Intel/AMD][flox_x86_64_deb_install]{:target="_blank" .md-button .md-button--primary}
             [64-bit ARM][flox_aarch64_deb_install]{:target="_blank" .md-button .md-button--primary}

        1. Install the downloaded file

            ``` { .text .code-command .copy }
            sudo dpkg -i /path/to/flox.deb
            ```

    ??? example "OracleLinux_8_5"

        **Install prerequisites**

        ``` { .text .code-command .copy }
        sudo yum install tar xz
        ```

        **Download and install the package**

        1. Download flox.rpm for your system architecture:

             [64-bit Intel/AMD][flox_x86_64_rpm_install]{:target="_blank" .md-button .md-button--primary}
             [64-bit ARM][flox_aarch64_rpm_install]{:target="_blank" .md-button .md-button--primary}

        1. Install the downloaded file


            ``` { .text .code-command .copy }
            sudo rpm -ivh /path/to/flox.rpm
            ```

    !!! info "Ignore warning about systemd"

        You will encounter the following warning during the installation:

        ```text
        ---- warning! ------------------------------------------------------------------
        We did not detect systemd on your system. With a multi-user install
        without systemd you will have to manually configure your init system to
        launch the Nix daemon after installation.
        ```

        You can disregard this message as we will be configuring the
        `nix-daemon` to start automatically in the next section.

    **Configure `nix-daemon` to start on activation**

    Once Flox has been installed on your WSL distribution the `nix-daemon` will
    need to be automatically started as you start your WSL instance.

    Run the following command to add the necessary logic to invoke `nix-daemon`
    by way of your `~/.bashrc` file:

    ``` { .text .code-command .copy }
    cat >> ~/.bashrc <<EOF
    ( wsl.exe -d $WSL_DISTRO_NAME -u root service nix-daemon status 2>&1 >/dev/null ) || wsl.exe -d $WSL_DISTRO_NAME -u root service nix-daemon start
    EOF
    ```

    Then restart your WSL shell (or start another) and run the following
    command to ensure that the `nix-daemon` is working correctly:

    ``` { .text .code-command .copy }
    nix --extra-experimental-features nix-command store ping
    ```
    **Verify Flox installation**

    If the following command returns without error then you're ready to get
    started!

    ``` console
    $ flox --version # (1)!
    {{ FLOX_VERSION }}

    ```

    1.  The version you will see might be different.

    **Upgrade existing Flox installation**

    Please follow the instructions provided on either the Debian or RPM tab
    (whichever matches the existing Linux Distribution installed with your
    WSL) to update to latest version of Flox.

[flox]: https://flox.dev
[flox_x86_64_deb_install]: https://downloads.flox.dev/by-env/stable/deb/flox-{{ FLOX_VERSION }}.x86_64-linux.deb
[flox_aarch64_deb_install]: https://downloads.flox.dev/by-env/stable/deb/flox-{{ FLOX_VERSION }}.aarch64-linux.deb
[flox_x86_64_rpm_install]: https://downloads.flox.dev/by-env/stable/rpm/flox-{{ FLOX_VERSION }}.x86_64-linux.rpm
[flox_aarch64_rpm_install]: https://downloads.flox.dev/by-env/stable/rpm/flox-{{ FLOX_VERSION }}.aarch64-linux.rpm
[flox_mac_apple_silicon_install]: https://downloads.flox.dev/by-env/stable/osx/flox-{{ FLOX_VERSION }}.aarch64-darwin.pkg
[flox_mac_intel_install]: https://downloads.flox.dev/by-env/stable/osx/flox-{{ FLOX_VERSION }}.x86_64-darwin.pkg
[flox_discourse]: https://discourse.flox.dev
[release_notes]: https://github.com/flox/flox/releases
