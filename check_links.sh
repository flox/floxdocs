#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

lychee $SCRIPT_DIR/site \
  -nv \
  --remap "https://flox.dev/docs file://$PWD/site"
