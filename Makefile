# Flox Documentation Makefile

.PHONY: help dev build clean install

# Default target
help:
	@echo "Available targets:"
	@echo "  dev     - Start development server with live reload"
	@echo "  build   - Build static site and generate AI files"
	@echo "  clean   - Clean build artifacts"
	@echo "  install - Install dependencies"
	@echo "  help    - Show this help message"

# Development server with live reload
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
	@echo "✅ Build complete! Site available in ./site/"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf site/
	rm -rf public/
	@echo "✅ Clean complete!"

# Install dependencies (if needed)
install:
	@echo "Installing dependencies..."
	@if command -v poetry >/dev/null 2>&1; then \
		poetry install; \
	else \
		echo "Poetry not found. Please install dependencies manually."; \
	fi
