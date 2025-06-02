FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONPATH="/app/libs/core:/app/libs/computer:/app/libs/agent:/app/libs/som:/app/libs/pylume:/app/libs/computer-server:/app/libs/mcp-server"

# Install only essential dependencies first
RUN apt-get update -o Acquire::AllowInsecureRepositories=true \
    -o Acquire::AllowDowngradeToInsecureRepositories=true \
    && apt-get install -y -o APT::Get::AllowUnauthenticated=true \
    --no-install-recommends \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the entire project
COPY . /app/

# Create a simple .env.local file for build.sh
RUN echo "PYTHON_BIN=python" > /app/.env.local

# Install build-essential separately to manage space better
RUN apt-get update -o Acquire::AllowInsecureRepositories=true \
    -o Acquire::AllowDowngradeToInsecureRepositories=true \
    && apt-get install -y -o APT::Get::AllowUnauthenticated=true \
    --no-install-recommends \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Modify build.sh to skip virtual environment creation
RUN sed -i 's/python -m venv .venv/echo "Skipping venv creation in Docker"/' /app/scripts/build.sh && \
    sed -i 's/source .venv\/bin\/activate/echo "Skipping venv activation in Docker"/' /app/scripts/build.sh && \
    sed -i 's/find . -type d -name ".venv" -exec rm -rf {} +/echo "Skipping .venv removal in Docker"/' /app/scripts/build.sh && \
    chmod +x /app/scripts/build.sh

# Run the build script to install dependencies
RUN cd /app && ./scripts/build.sh

# Install remaining dependencies after Python packages are installed
RUN apt-get update -o Acquire::AllowInsecureRepositories=true \
    -o Acquire::AllowDowngradeToInsecureRepositories=true \
    && apt-get install -y -o APT::Get::AllowUnauthenticated=true \
    --no-install-recommends \
    xvfb \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Default command - start all services
CMD ["/bin/bash", "-c", "Xvfb :99 -screen 0 1024x768x24 & export DISPLAY=:99 && python -m computer.server --port 8006 & python -m mcp_server & python -m agent.ui.gradio.app --server-port 7860 --server-name 0.0.0.0"]