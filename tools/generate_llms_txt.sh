#!/usr/bin/env bash

# Generate AI files for local development
# This script should be run after mkdocs builds the site

set -euo pipefail

# Ensure site directory exists
if [ ! -d "site" ]; then
    echo "Error: site directory not found. Please run 'mkdocs build' first."
    exit 1
fi

# Generate both AI files
python3 tools/generate_llms_txt.py ./site

echo "✅ Generated both llms.txt (for agents) and docs-content.txt (for answer engines)"


