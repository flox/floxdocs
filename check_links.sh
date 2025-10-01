#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Check links, excluding the bash manual and the docs for GNU Make (returns a 429)
# Backblaze also 429's
lychee $SCRIPT_DIR/site \
  -nv \
  --remap "https://flox.dev/docs file://$PWD/site" \
  --exclude "bash/man/html_node" \
  --exclude "https://www.gnu.org/software/make/" \
  --exclude "https://github.com/flox/catalog-util" \
  --exclude "https://www.backblaze.com/cloud-storage"
