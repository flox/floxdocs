# Tools

This directory contains build tools and utilities for the Flox documentation site.

## Scripts

### `generate_llms_txt.py`

Generates AI-friendly documentation files from the built MkDocs site:

- **`llms.txt`** - Agent-focused file with critical rules, workflows, and organized sitemap
- **`docs-content.txt`** - Answer engine file with comprehensive documentation content

**Usage:**
```bash
python3 tools/generate_llms_txt.py <site_directory>
```

### `generate_llms_txt.sh`

Convenience script for local development. Generates both AI files after a MkDocs build.

**Usage:**
```bash
mkdocs build
./tools/generate_llms_txt.sh
```

## Integration

These scripts are automatically run during CI builds in `.github/workflows/ci.yml` to ensure the AI files are always up-to-date with the documentation content.
