#!/bin/bash

# Sets up per-project opencode data and configuration directories.
# It uses a Docker volume mounted at /mnt/opencode-workspace, creating a
# unique subfolder based on the host's project path so each project stays isolated.

set -e

# Compute a sanitized host-path-based directory name under the volume mount.
OPENCODE_DATA_DIR="/mnt/opencode-workspace/$(printf '%s' "${LOCAL_WORKSPACE_FOLDER}" | sed 's|^/||; s|:||g; s|\\|/|g; s|/|_|g')"
OPENCODE_SHARE=".local/share/opencode"
OPENCODE_CONFIG=".config/opencode"

mkdir -p ${OPENCODE_DATA_DIR}
mkdir -p ${OPENCODE_DATA_DIR}/${OPENCODE_SHARE}
mkdir -p ${OPENCODE_DATA_DIR}/${OPENCODE_CONFIG}

# Symlink the opencode share directory (conversation history, etc.) into the volume.
if [ -L "${HOME}/${OPENCODE_SHARE}" ]; then
    echo "Opencode share is already a symbolic link."
else
    if [ -d "${HOME}/${OPENCODE_SHARE}" ]; then
        echo "Opencode share directory exists and is not a symbolic link. Backing up existing directory."
        mv "${HOME}/${OPENCODE_SHARE}" "${HOME}/${OPENCODE_SHARE}.backup"
    fi
    mkdir -p "${HOME}/.local/share"
    ln -s "${OPENCODE_DATA_DIR}/${OPENCODE_SHARE}" "${HOME}/${OPENCODE_SHARE}"
    echo "Created symbolic link for Opencode share."
fi

# Symlink the opencode config directory into the volume.
if [ -L "${HOME}/${OPENCODE_CONFIG}" ]; then
    echo "Opencode config is already a symbolic link."
else
    if [ -d "${HOME}/${OPENCODE_CONFIG}" ]; then
        echo "Opencode config directory exists and is not a symbolic link. Backing up existing directory."
        mv "${HOME}/${OPENCODE_CONFIG}" "${HOME}/${OPENCODE_CONFIG}.backup"
    fi
    mkdir -p "${HOME}/.config"
    ln -s "${OPENCODE_DATA_DIR}/${OPENCODE_CONFIG}" "${HOME}/${OPENCODE_CONFIG}"
    echo "Created symbolic link for Opencode config."
fi

# Seed the default opencode.json if one doesn't already exist in the volume.
if ! [ -f "${OPENCODE_DATA_DIR}/${OPENCODE_CONFIG}/opencode.json" ]; then
    echo "Copying default opencode.json config to the data directory."
    cp -r ${CONTAINER_WORKSPACE_FOLDER}/.devcontainer/data/.config/opencode/* ${OPENCODE_DATA_DIR}/${OPENCODE_CONFIG}
fi
