---
title: Known issues
description: Known issues
---

# Known issues

## Build

### False positive dependencies

Currently it's possible for false positive detection of missing dependencies.
For example, the Go compiler embeds metadata into compiled binaries, including the path to the compiler itself.
When scanning a Go-compiled binary for references to missing dependencies, Nix will detect a reference to the Go compiler and erroneously claim that your binary depends on the Go compiler.

The mitigation for this bug varies from language to language, but in this Go case the mitigation is as simple as using the `-trimpath` compilation flag.

It's also worth noting that sometimes what appears as a false positive missing dependency is actually a runtime dependency that you wouldn't know is missing until a certain codepath in your executable is triggered.
In short, ensure that you've done your due diligence to find out whether a missing dependency is actually a false positive.
