#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

lychee $SCRIPT_DIR/site \
  -nv \
  --exclude "file://" \
  --exclude "s3://" \
  --exclude "https://alpha.floxsdlc.com"
