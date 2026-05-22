FROM mcr.microsoft.com/devcontainers/base:noble

# Install basic dependencies.
RUN apt-get update \
    && apt-get -y install \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the shared volume mount point and give the vscode user ownership.
RUN mkdir /mnt/opencode-workspace \
    && chown vscode:vscode /mnt/opencode-workspace

USER vscode
