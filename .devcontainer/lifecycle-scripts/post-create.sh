#!/bin/bash

# Orchestrator for post-create lifecycle scripts.
# It makes all .sh files in the post-create directory executable, then runs
# each one in sorted order. Files prefixed with an underscore (_) are skipped.

set -e

chmod +x ${CONTAINER_WORKSPACE_FOLDER}/.devcontainer/lifecycle-scripts/post-create/*.sh

for script in $(ls -1 ${CONTAINER_WORKSPACE_FOLDER}/.devcontainer/lifecycle-scripts/post-create/*.sh | sort); do
    if [ -f "$script" ] && [[ "$(basename "$script")" != _* ]]; then
        echo "Running post-create script: $script"
        bash "$script"
    fi
done
