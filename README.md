# Homebrew Tap for Forbin

This is the official Homebrew tap for [Forbin](https://github.com/chris-colinsky/Forbin), an interactive CLI tool for testing remote MCP (Model Context Protocol) servers.

## Installation

```bash
brew tap chris-colinsky/forbin
brew install forbin
```

## Usage

After installation, configure your environment:

```bash
# Create config directory
mkdir -p ~/.config/forbin

# Create .env file with your MCP server details
cat > ~/.config/forbin/.env << EOF
MCP_SERVER_URL=https://your-server.fly.dev/mcp
MCP_TOKEN=your-secret-token
MCP_HEALTH_URL=https://your-server.fly.dev/health
EOF
```

Run Forbin:

```bash
# Interactive mode
forbin

# Test connectivity only
forbin --test

# Help
forbin --help
```

## Updating

```bash
brew update
brew upgrade forbin
```

## Uninstalling

```bash
brew uninstall forbin
brew untap chris-colinsky/forbin
```

## What is Forbin?

Forbin is an interactive CLI tool for testing remote MCP (Model Context Protocol) servers. Named after Dr. Charles Forbin from "Colossus: The Forbin Project" (1970), it's designed for developers building agentic workflows and testing FastAPI/FastMCP-based remote tools.

### Features

- Interactive tool browser with parameter input
- Automatic server wake-up for suspended services (Fly.io, etc.)
- Cold-start resilient connection logic
- Type-safe parameter parsing
- Connectivity testing mode

For more information, visit the [main repository](https://github.com/chris-colinsky/Forbin).

## License

MIT License - see [LICENSE](https://github.com/chris-colinsky/Forbin/blob/main/LICENSE) for details.
