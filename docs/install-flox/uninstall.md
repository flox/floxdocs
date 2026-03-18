---
title: Uninstall Flox
description: How to uninstall the Flox CLI
---

# Uninstall Flox { #uninstall-flox }

While we are sad we see you uninstalling `flox` we would like **thank you**
for giving `flox` a try.

As we try to improve `flox` we really appreciate any feedback, especially
where we failed. We like to know what was not working or where could we do
a better job. Please reach us [via
discourse][flox_discourse]{:target="_blank"} or [via
email](mailto:hello@flox.dev).

Here's how to **completely remove `flox` from your system**.

{%
    include-markdown "include/uninstalling-Flox-package.md"
%}

=== "Nix - Generic"

    If you've installed flox to the system-wide `default` profile

    ``` { .text .code-command .copy }
    sudo -H nix profile remove \
            '.*flox' \
            --profile /nix/var/nix/profiles/default \
            --experimental-features "nix-command flakes"
    ```

    Or, if you've installed flox to your own _personal_ profile

    ``` { .text .code-command .copy }
    nix profile remove \
            '.*flox' \
            --experimental-features "nix-command flakes"
    ```

    Or, if you've declared Flox using a flake, remove the Flake

=== "WSL"

    Please follow the instructions provided on either the Debian or RPM tab
    (whichever matches the existing Linux Distribution installed with your
    WSL) to uninstall Flox.

[flox_discourse]: https://discourse.flox.dev
