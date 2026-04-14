---
title: Extensions
description: IDE extensions and AI agent integrations for Flox
---

# Extensions

=== "Skills and MCP"

    [Flox Agentic][agentic] provides a skill library and MCP server
    that give AI coding agents expert knowledge of Flox environments,
    builds, services, containers, publishing, and CUDA.

    **Skills included:** `flox-environments`, `flox-services`,
    `flox-builds`, `flox-containers`, `flox-publish`,
    `flox-sharing`, `flox-cuda`

    ## Claude Code

    The Flox plugin for Claude Code installs both the skill library
    and MCP server in one step:

    ```{ .sh .code-command .copy }
    claude plugin marketplace add flox/flox-agentic
    ```

    ```{ .sh .code-command .copy }
    claude plugin install flox@flox-agentic
    ```

    ## Other agents (skills.sh)

    For Cursor, Copilot, Windsurf, Gemini, and 15+ other agents,
    use [skills.sh][skillssh] — a third-party open agent skills
    ecosystem:

    ```{ .sh .code-command .copy }
    npx skills add flox/flox-agentic
    ```

    !!! note "Third-party tool"
        skills.sh is not maintained by Flox. It requires Node.js.
        See [skills.sh][skillssh] for supported agents and docs.

    ## MCP server

    For agents that support the
    [Model Context Protocol][mcp] directly, install the MCP server:

    ```{ .sh .code-command .copy }
    flox install flox/flox-mcp-server
    ```

    Then point your client at the `flox-mcp` command using stdio
    transport. For Cursor, add to `~/.cursor/mcp.json`:

    ```{ .json .copy }
    {
      "mcpServers": {
        "flox": {
          "command": "flox-mcp"
        }
      }
    }
    ```

    ## Learn more

    Full documentation and source code:
    [github.com/flox/flox-agentic][agentic]

    [agentic]: https://github.com/flox/flox-agentic
    [mcp]: https://modelcontextprotocol.io
    [skillssh]: https://skills.sh

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
