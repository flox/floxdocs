<!-- markdownlint-disable-file MD041 -->
=== "MacOS (Pkg)"

    !!! warning "The following commands will completely remove Nix and the contents of `/nix/*` from the system."

    Be sure to back up the system and/or extract any important Nix-related
    files and packages before continuing.

    1. Ensure no running processes are using `/nix`.

    1. Run:

        ``` { .text .code-command .copy }
        sudo /usr/local/share/flox/scripts/uninstall
        ```

    Regardless of the current state, brew can be used to perform a full clean up:
    ``` { .text .code-command .copy }
    brew uninstall --force --zap flox
    ```

    We recommend rebooting your system after uninstalling Flox.
=== "MacOS (Homebrew)"

    !!! warning "The following commands will completely remove Nix and the contents of `/nix/*` from the system."

    Be sure to back up the system and/or extract any important Nix-related
    files and packages before continuing.

    !!! note "You may be asked if the terminal has permission to modify contents of the disk."

    Run:

    ``` { .text .code-command .copy }
    brew uninstall flox
    ```

    To remove all traces of flox including user preferences uninstall with:

    ``` { .text .code-command .copy }
    brew uninstall --zap flox
    ```

    In the case of recovering a partial install, a force and zap can help:
    ``` { .text .code-command .copy }
    brew uninstall --force --zap flox
    ```

    We recommend rebooting your system after uninstalling Flox.

=== "Debian"

    For use on Debian, Ubuntu, and other Debian-based distributions.

    !!! warning "The following command will completely remove Nix and the contents of `/nix/*` from the system."

    Be sure to back up the system and/or extract any important Nix-related
    files and packages before continuing.

    ``` { .text .code-command .copy }
    sudo apt-get purge flox
    ```

    We recommend rebooting your system after uninstalling Flox.

=== "RPM"

    For use on RedHat, CentOS, Amazon Linux, and other RPM-based
    distributions.

    !!! warning "The following command will completely remove Nix and the contents of `/nix/*` from the system."

    Be sure to back up the system and/or extract any important Nix-related
    files and packages before continuing.

    ``` { .text .code-command .copy }
    sudo yum remove flox
    ```

    We recommend rebooting your system after uninstalling Flox.

    ??? info "Output on success:"

        ```
        $ sudo yum remove flox
        Updating Subscription Management repositories.
        Unable to read consumer identity

        This system is not registered to Red Hat Subscription Management.
        You can use subscription-manager to register.

        Dependencies resolved.
        ======================================================================
            Package       Architecture    Version              Repository   Size
        ======================================================================
        Removing:
            flox          x86_64          1.4.3-1625910780     @@System     109 M

        Transaction Summary
        ======================================================================
        Remove  1 Package

        Freed space: 109 M
        Is this ok [y/N]: y
        Running transaction check
        Transaction check succeeded.
        Running transaction test
        Transaction test succeeded.
        Running transaction
            Preparing        :                                               1/1
            Running scriptlet: flox-1.4.3-1625910780.x86_64                  1/1
        floxadm uninstall complete

            Erasing          : flox-1.4.3-1625910780.x86_64                  1/1
            Running scriptlet: flox-1.4.3-1625910780.x86_64                  1/1
            Verifying        : flox-1.4.3-1625910780.x86_64                  1/1
        Installed products updated.

        Removed:
            flox-1.4.3-1625910780.x86_64

        Complete!
        ```
