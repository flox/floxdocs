#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

exec tesh --verbose --no-debug \
  $SCRIPT_DIR/docs/index.md \
  $SCRIPT_DIR/docs/cookbook/validate-identical.md \
  $SCRIPT_DIR/docs/tutorials/build-container-images.md \
  $SCRIPT_DIR/docs/tutorials/managed-environments.md
