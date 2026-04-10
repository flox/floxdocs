# Flox Documentation
# Run `just` to see available recipes

# Show available recipes
default:
    @just --list

# Start development server with live reload
dev:
    @echo "Starting development server..."
    @echo "Site will be available at: http://127.0.0.1:8000"
    @echo "Press Ctrl+C to stop"
    mkdocs serve

# Build static site and generate AI files
build:
    @echo "Building static site..."
    mkdocs build
    @echo "Generating AI files..."
    python3 tools/generate_llms_txt.py ./site
    @echo "Build complete! Site available in ./site/"

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    rm -rf site/
    rm -rf public/
    @echo "Clean complete!"
