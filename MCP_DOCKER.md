# CUA MCP Server in Docker

The MCP (Model Context Protocol) server is included in the Docker container and can be used with Claude Desktop or other MCP clients.

## How MCP Server Works

The MCP server uses stdio (standard input/output) for communication, which means:
- It reads JSON-RPC messages from stdin
- It writes responses to stdout
- It's designed to be launched by MCP clients like Claude Desktop

## Running MCP Server in Docker

### Option 1: Direct stdio connection (for testing)
```bash
# Run interactively
docker run -it --rm cua-app python -m mcp_server
```

### Option 2: Using Docker Compose
The docker-compose.yml includes an MCP server service that keeps stdin open:
```bash
docker-compose up mcp-server
```

### Option 3: For Claude Desktop Integration

Since MCP servers communicate via stdio, you typically need to configure Claude Desktop to launch the Docker container. However, this is tricky because:

1. MCP expects to launch the server process directly
2. Docker containers add an extra layer of process management

## Workaround for Claude Desktop

Create a wrapper script on your host machine:

```bash
#!/bin/bash
# mcp-cua-wrapper.sh
docker run -i --rm \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  -v /path/to/cua:/app \
  cua-app python -m mcp_server
```

Then configure Claude Desktop to use this wrapper script.

## What the MCP Server Provides

The CUA MCP server exposes:
- Tools for computer control (screenshots, mouse, keyboard)
- Agent capabilities for automation
- Integration with various LLM providers

## Note on Architecture

The MCP server in the Docker container can:
- Control Linux desktop environments within the container
- Connect to remote computers via the Computer API
- Use cloud-based CUA containers (with API key)

But it cannot:
- Control macOS VMs (requires running on Mac hardware with Lume)
- Access the host machine's desktop directly
