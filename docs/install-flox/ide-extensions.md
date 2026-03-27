---
title: Extensions
description: IDE extensions and AI agent integrations for Flox
---

# Extensions

=== "VS Code"

    The [Flox extension for VS Code][marketplace] brings full
    environment management into VS Code and compatible editors
    like [Cursor][cursor].

    ## Install from the Marketplace

    !!! note "Requirements"
        - Flox CLI installed ([install instructions](install.md))
        - VS Code 1.87.0 or later

    1. Open the Extensions view (++cmd+shift+x++ on macOS,
       ++ctrl+shift+x++ on Linux)
    2. Search for **Flox**
    3. Click **Install**

    ## Build and install from source

    If you prefer to install manually, you can build a `.vsix` file
    from the source repository:

    1. Clone the repository and check out a release tag:

        ```{ .sh .code-command .copy }
        git clone https://github.com/flox/flox-vscode.git
        cd flox-vscode
        git checkout v1.0.1
        ```

    2. Activate the Flox environment and build the package:

        ```{ .sh .code-command .copy }
        flox activate
        npm run package
        ```

        This creates a `.vsix` file in the project directory.

    3. Install the `.vsix` file using the Command Palette
       (++cmd+shift+p++ on macOS, ++ctrl+shift+p++ on Linux):

        - Run **Extensions: Install from VSIX...**
        - Select the generated `.vsix` file

        Or install from the command line:

        ```{ .sh .code-command .copy }
        code --install-extension flox-*.vsix
        ```

    ## Source code

    The extension is open source:
    [github.com/flox/flox-vscode][repo]

    [marketplace]: https://marketplace.visualstudio.com/items?itemName=flox.flox
    [cursor]: https://cursor.com
    [repo]: https://github.com/flox/flox-vscode

=== "MCP and Skills"

    [Flox Agentic][agentic] is a skill library and MCP server
    that gives AI coding agents access to Flox environments.

    ## Install the MCP server

    Every editor needs the Flox MCP server package:

    ```{ .sh .code-command .copy }
    flox install flox/flox-mcp-server
    ```

    ## Claude Code (recommended)

    The Flox Agentic plugin for Claude Code adds seven expert
    skills and configures the MCP connection automatically:

    ```{ .sh .code-command .copy }
    /plugin marketplace add flox/flox-agentic
    ```

    ```{ .sh .code-command .copy }
    /plugin install flox@flox-agentic
    ```

    The skills cover environments, services, builds,
    containers, publishing, sharing, and CUDA development.

    ## Cursor

    Add the following to `~/.cursor/mcp.json`:

    ```{ .json .copy }
    {
      "mcpServers": {
        "flox": {
          "command": "flox-mcp"
        }
      }
    }
    ```

    ## Other MCP clients

    Point your client at the `flox-mcp` command using stdio
    transport.

    ## Learn more

    Full documentation and source code:
    [github.com/flox/flox-agentic][agentic]

    [agentic]: https://github.com/flox/flox-agentic
    [mcp]: https://modelcontextprotocol.io
