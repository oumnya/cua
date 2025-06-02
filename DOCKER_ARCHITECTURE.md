# Running macOS and Linux VMs with CUA Docker Architecture

## The Complete Picture

CUA's claim of running "macOS & Linux Containers" works through a clever architecture:

### 1. For macOS VMs (Requires Mac Hardware)

```bash
# Step 1: Install and run Lume service on your Mac host
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)"

# Step 2: Run Lumier Docker container that connects to Lume
docker run -it --rm \
    --name macos-vm \
    -p 8006:8006 \
    -e VM_NAME=macos-vm \
    -e VERSION=ghcr.io/trycua/macos-sequoia-cua:latest \
    -e CPU_CORES=4 \
    -e RAM_SIZE=8192 \
    trycua/lumier:latest
```

**Architecture:**
- Lumier (Docker) → Lume (Host Mac) → Apple Virtualization Framework → macOS VM
- Docker is just the interface layer, not the virtualization layer

### 2. For Linux Containers (Works Anywhere)

```bash
# Standard Docker container with Linux environment
docker run -it --rm \
    -p 8006:8006 \
    -e PYTHONPATH="/app/libs/core:/app/libs/computer:/app/libs/agent" \
    cua-app
```

### 3. Complete Docker Compose Setup

```yaml
version: '3.8'

services:
  # For macOS VMs (requires Lume on host)
  lumier-macos:
    image: trycua/lumier:latest
    container_name: cua-macos-vm
    ports:
      - "8006:8006"  # VNC access
    environment:
      - VM_NAME=cua-macos
      - VERSION=ghcr.io/trycua/macos-sequoia-cua:latest
      - CPU_CORES=4
      - RAM_SIZE=8192
      - LUME_API_HOST=host.docker.internal  # Connects to Lume on host
    volumes:
      - ./storage:/storage
      - ./shared:/shared
    depends_on:
      - cua-server

  # CUA Server (controls VMs)
  cua-server:
    build: .
    container_name: cua-server
    ports:
      - "7777:7777"  # Computer server
    environment:
      - PYTHONPATH=/app/libs/core:/app/libs/computer:/app/libs/agent
    volumes:
      - ./:/app
    command: python -m computer.server

  # Agent UI
  cua-ui:
    build: .
    container_name: cua-ui
    ports:
      - "7860:7860"
    environment:
      - PYTHONPATH=/app/libs/core:/app/libs/computer:/app/libs/agent
    volumes:
      - ./:/app
    command: python -m agent.ui.gradio.app --server-port 7860 --server-name 0.0.0.0

  # For Linux containers (true Docker containers)
  cua-linux:
    build: .
    container_name: cua-linux
    environment:
      - DISPLAY=:99
      - PYTHONPATH=/app/libs/core:/app/libs/computer:/app/libs/agent
    volumes:
      - ./:/app
    command: |
      bash -c "
        Xvfb :99 -screen 0 1024x768x24 &
        sleep infinity
      "
```

## How Their Cloud Service Works

1. **Linux Containers**: Standard Docker/Kubernetes deployment
2. **macOS "Containers"**: 
   - They have Mac hardware in their data centers
   - Lume service runs on these Macs
   - Customer containers connect to these Lume instances
   - Provides macOS VMs that feel like containers via API

## Key Takeaway

The "Docker for Computer-Use Agents" tagline is accurate but nuanced:
- **Linux**: True containerization
- **macOS**: VM orchestration through containerized interfaces
- Both accessible through the same API/interface
