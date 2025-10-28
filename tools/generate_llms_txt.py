#!/usr/bin/env python3
"""
Generate llms.txt from the built MkDocs site.
This script scans the built site directory and creates a comprehensive llms.txt file.
"""

import os
import re
import sys
from pathlib import Path
from urllib.parse import unquote


def normalize_url(path: str, base_url: str = "https://flox.dev/docs") -> str:
    """Convert file path to URL."""
    # Remove leading/trailing slashes
    path = path.strip('/')
    if not path or path == 'index.html':
        return base_url
    # Remove .html extension
    path = path.replace('.html', '')
    return f"{base_url}/{path}"


def extract_title_from_html(html_content: str) -> str:
    """Extract page title from HTML content."""
    # Check if this is a redirect page
    if 'Redirecting...' in html_content or 'redirect' in html_content.lower():
        return None  # Signal this is a redirect page
    
    # Try to find the first h1 tag
    h1_match = re.search(r'<h1[^>]*>(.*?)</h1>', html_content, re.DOTALL)
    if h1_match:
        title = h1_match.group(1).strip()
        # Remove markdown tags and clean up
        title = re.sub(r'<[^>]+>', '', title)
        return title
    
    # Fallback to title tag
    title_match = re.search(r'<title>(.*?)</title>', html_content, re.DOTALL)
    if title_match:
        title = title_match.group(1).strip()
        title = title.replace(' - Flox Docs', '').strip()
        return title
    
    return "Untitled"


def extract_description_from_html(html_content: str) -> str:
    """Extract meta description or first paragraph."""
    # Try to find meta description
    desc_match = re.search(r'<meta\s+name=["\']description["\']\s+content=["\']([^"\']+)["\']', html_content)
    if desc_match:
        return desc_match.group(1)
    
    # Try to find first paragraph in content
    # Look for content area (often has specific class or ID)
    para_match = re.search(r'<main[^>]*>.*?<p[^>]*>(.*?)</p>', html_content, re.DOTALL)
    if para_match:
        desc = para_match.group(1).strip()
        # Remove HTML tags
        desc = re.sub(r'<[^>]+>', '', desc)
        # Limit length
        if len(desc) > 200:
            desc = desc[:200] + "..."
        return desc
    
    return ""


def categorize_page(url: str, title: str) -> str:
    """Categorize pages for better organization."""
    if '/concepts/' in url:
        return 'concepts'
    elif '/tutorials/' in url:
        return 'tutorials'
    elif '/man/' in url:
        return 'manual'
    elif '/languages/' in url:
        return 'languages'
    elif '/install-flox/' in url:
        return 'installation'
    elif '/customer/' in url:
        return 'customer'
    elif '/snippets/' in url:
        return 'snippets'
    elif url.endswith('/docs') or url.endswith('/docs/'):
        return 'overview'
    else:
        return 'other'


def get_page_description(url: str, title: str) -> str:
    """Get a helpful description for common pages."""
    descriptions = {
        'concepts/environments': 'Understanding Flox environments and how they work',
        'concepts/activation': 'How to activate and use Flox environments',
        'concepts/floxhub': 'Understanding FloxHub package registry and sharing',
        'concepts/generations': 'Environment snapshots and version management',
        'concepts/packages-and-catalog': 'Package management and the Flox catalog',
        'concepts/services': 'Running services within Flox environments',
        'concepts/composition': 'Combining and layering multiple environments',
        'concepts/builds': 'Building packages and environments',
        'concepts/publishing': 'Publishing packages to FloxHub',
        'tutorials/creating-environments': 'Step-by-step guide to create your first environment',
        'tutorials/sharing-environments': 'How to share environments with team members',
        'tutorials/customizing-environments': 'Customizing shell environment and behavior',
        'tutorials/build-and-publish': 'Building and publishing custom packages',
        'tutorials/ci-cd': 'Using Flox in continuous integration pipelines',
        'tutorials/composition': 'Reusing and combining developer environments',
        'tutorials/multi-arch-environments': 'Cross-platform environment design',
        'tutorials/cuda': 'Using CUDA with Flox environments',
        'tutorials/migrations/homebrew': 'Migrating from Homebrew to Flox',
        'tutorials/migrations/nvm': 'Migrating from Node Version Manager to Flox',
        'languages/python': 'Python development with Flox',
        'languages/nodejs': 'Node.js and JavaScript development',
        'languages/go': 'Go development with Flox',
        'languages/rust': 'Rust development with Flox',
        'languages/c': 'C/C++ development with Flox',
        'languages/jvm': 'Java and JVM development',
        'languages/ruby': 'Ruby development with Flox',
        'install-flox/install': 'Installation instructions for Flox',
        'install-flox/uninstall': 'How to uninstall Flox',
        'flox-5-minutes': 'Quick start guide to get up and running',
    }
    
    # Extract the key part of the URL
    key = url.replace('https://flox.dev/docs/', '').replace('/index', '')
    return descriptions.get(key, '')


def get_site_structure(site_dir: Path) -> list:
    """Get all pages from the built site."""
    pages = []
    html_files = list(site_dir.rglob('*.html'))
    
    for html_file in sorted(html_files):
        # Skip generated JS/search files
        if html_file.name in ['search.html', '404.html', 'sitemap.xml']:
            continue
        
        rel_path = html_file.relative_to(site_dir)
        url = normalize_url(str(rel_path))
        
        try:
            with open(html_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            title = extract_title_from_html(content)
            
            # Skip redirect pages
            if title is None:
                continue
                
            description = extract_description_from_html(content)
            
            description = get_page_description(url, title)
            category = categorize_page(url, title)
            
            pages.append({
                'url': url,
                'title': title,
                'path': str(rel_path),
                'description': description,
                'category': category
            })
        except Exception as e:
            print(f"Error processing {html_file}: {e}", file=sys.stderr)
    
    return pages


def extract_page_content(html_content: str) -> str:
    """Extract main content from HTML for answer engine."""
    # Remove script and style elements
    content = re.sub(r'<script[^>]*>.*?</script>', '', html_content, flags=re.DOTALL)
    content = re.sub(r'<style[^>]*>.*?</style>', '', content, flags=re.DOTALL)
    
    # Extract main content area
    main_match = re.search(r'<main[^>]*>(.*?)</main>', content, re.DOTALL)
    if main_match:
        content = main_match.group(1)
    
    # Remove unwanted elements
    content = re.sub(r'<nav[^>]*>.*?</nav>', '', content, flags=re.DOTALL)
    content = re.sub(r'<footer[^>]*>.*?</footer>', '', content, flags=re.DOTALL)
    content = re.sub(r'<aside[^>]*>.*?</aside>', '', content, flags=re.DOTALL)
    
    # Remove license/copyright text
    content = re.sub(r'Permission is hereby granted.*?DEALINGS IN THE SOFTWARE\.', '', content, flags=re.DOTALL)
    content = re.sub(r'Copyright.*?All rights reserved\.', '', content, flags=re.DOTALL)
    content = re.sub(r'THE SOFTWARE IS PROVIDED.*?DEALINGS IN THE SOFTWARE\.', '', content, flags=re.DOTALL)
    content = re.sub(r'-->.*?Have questions\?', '', content, flags=re.DOTALL)
    
    # Remove HTML tags but preserve structure
    content = re.sub(r'<h([1-6])[^>]*>(.*?)</h[1-6]>', r'\n\n#\1 \2\n', content)
    content = re.sub(r'<p[^>]*>(.*?)</p>', r'\1\n\n', content)
    content = re.sub(r'<li[^>]*>(.*?)</li>', r'- \1\n', content)
    content = re.sub(r'<code[^>]*>(.*?)</code>', r'`\1`', content)
    content = re.sub(r'<pre[^>]*><code[^>]*>(.*?)</code></pre>', r'```\n\1\n```', content, flags=re.DOTALL)
    content = re.sub(r'<[^>]+>', '', content)
    
    # Clean up whitespace and remove empty lines
    content = re.sub(r'\n\s*\n\s*\n', '\n\n', content)
    content = re.sub(r'^\s*\n', '', content, flags=re.MULTILINE)
    content = content.strip()
    
    # Only return substantial content (more than 100 chars)
    if len(content) < 100:
        return ""
    
    return content


def generate_llms_txt(site_dir: Path, output_path: Path):
    """Generate llms.txt file for agents."""
    pages = get_site_structure(site_dir)
    
    # Read existing llms.txt to get the header
    existing_llms = Path('docs/llms.txt')
    header = ""
    if existing_llms.exists():
        with open(existing_llms, 'r') as f:
            lines = f.readlines()
            # Extract header (everything before the Sitemap section)
            for i, line in enumerate(lines):
                if line.startswith('## Sitemap'):
                    header = ''.join(lines[:i])
                    break
                header = ''.join(lines)
    
    # Add key terminology section
    terminology = """
## Key Terms
- **Environment**: A reproducible development environment with specific packages and configurations
- **Manifest**: A declarative configuration file (manifest.toml) defining an environment's packages and settings
- **Generation**: A snapshot of an environment at a specific point in time, allowing rollbacks
- **FloxHub**: The package registry and sharing platform for Flox environments
- **Activation**: Running commands within a Flox environment's context
- **Catalog**: The collection of available packages that can be installed
- **Services**: Long-running processes defined in the manifest that can be managed by Flox

## Quick Reference
### Common Workflows
- **New Project**: `flox init -d .` → `flox install -d . <packages>` → `flox activate -d . -- <command>`
- **Multi-environment Project**: `flox init -d backend` + `flox init -d frontend`
- **Sharing Environment**: `flox push` → `flox pull` on another machine
- **Package Management**: `flox search <term>` → `flox show <package>` → `flox install -d . <package>`
- **Service Management**: Define in manifest → `flox services start <service>` → `flox services status`

"""
    
    # Group pages by category
    categories = {}
    for page in pages:
        cat = page['category']
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(page)
    
    # Generate organized sitemap
    sitemap = ["## Documentation Structure\n"]
    
    # Define category order and titles
    category_order = [
        ('overview', 'Overview'),
        ('installation', 'Installation'),
        ('tutorials', 'Tutorials & Getting Started'),
        ('concepts', 'Core Concepts'),
        ('languages', 'Language-Specific Guides'),
        ('manual', 'Command Reference'),
        ('customer', 'Customer Resources'),
        ('snippets', 'Code Snippets'),
        ('other', 'Other')
    ]
    
    for cat_key, cat_title in category_order:
        if cat_key in categories:
            sitemap.append(f"### {cat_title}\n")
            for page in sorted(categories[cat_key], key=lambda x: x['title']):
                if page['description']:
                    sitemap.append(f"- [{page['title']}]({page['url']}) - {page['description']}\n")
                else:
                    sitemap.append(f"- [{page['title']}]({page['url']})\n")
            sitemap.append("\n")
    
    # Write the complete llms.txt
    content = header + terminology + ''.join(sitemap)
    
    with open(output_path, 'w') as f:
        f.write(content)
    
    print(f"Generated {output_path} with {len(pages)} pages organized into {len(categories)} categories")


def generate_docs_content(site_dir: Path, output_path: Path):
    """Generate docs-content.txt file for answer engines."""
    pages = get_site_structure(site_dir)
    
    # Start with introduction
    content = """# Flox Documentation Content

This file contains comprehensive documentation content for answer engines and RAG systems.

"""
    
    # Group pages by category and add content
    categories = {}
    for page in pages:
        cat = page['category']
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(page)
    
    # Define category order and titles
    category_order = [
        ('overview', 'Overview'),
        ('installation', 'Installation'),
        ('tutorials', 'Tutorials & Getting Started'),
        ('concepts', 'Core Concepts'),
        ('languages', 'Language-Specific Guides'),
        ('manual', 'Command Reference'),
        ('customer', 'Customer Resources'),
        ('snippets', 'Code Snippets'),
        ('other', 'Other')
    ]
    
    for cat_key, cat_title in category_order:
        if cat_key in categories:
            content += f"\n## {cat_title}\n\n"
            
            for page in sorted(categories[cat_key], key=lambda x: x['title']):
                content += f"### {page['title']}\n"
                content += f"URL: {page['url']}\n\n"
                
                if page['description']:
                    content += f"**Description**: {page['description']}\n\n"
                
                # Try to extract content from the HTML file
                html_file = site_dir / page['path']
                try:
                    with open(html_file, 'r', encoding='utf-8') as f:
                        html_content = f.read()
                    
                    page_content = extract_page_content(html_content)
                    if page_content and len(page_content) > 200:  # Only include substantial content
                        content += page_content + "\n\n"
                    else:
                        content += f"*Content available at: {page['url']}*\n\n"
                except Exception as e:
                    content += f"*Content available at: {page['url']}*\n\n"
                
                content += "---\n\n"
    
    # Write the complete docs-content.txt
    with open(output_path, 'w') as f:
        f.write(content)
    
    print(f"Generated {output_path} with comprehensive documentation content")


def main():
    if len(sys.argv) < 2:
        print("Usage: generate_llms_txt.py <site_directory>")
        sys.exit(1)
    
    site_dir = Path(sys.argv[1])
    
    if not site_dir.exists():
        print(f"Error: Directory {site_dir} does not exist")
        sys.exit(1)
    
    # Generate files in temp location first, then copy to site root
    import tempfile
    import shutil
    
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        llms_temp = temp_path / 'llms.txt'
        docs_content_temp = temp_path / 'docs-content.txt'
        
        print("Generating files for AI systems...")
        generate_llms_txt(site_dir, llms_temp)
        generate_docs_content(site_dir, docs_content_temp)
        
        # Copy to site root
        llms_final = site_dir / 'llms.txt'
        docs_content_final = site_dir / 'docs-content.txt'
        
        shutil.copy2(llms_temp, llms_final)
        shutil.copy2(docs_content_temp, docs_content_final)
        
        print("✅ Generated both llms.txt (for agents) and docs-content.txt (for answer engines)")


if __name__ == '__main__':
    main()


