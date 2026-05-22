# opencode Devcontainer Starter

This repository is a starter project for running [opencode](https://opencode.ai) inside a VS Code Devcontainer. It provides a reproducible, containerized environment with opencode pre-installed and configured.

---

## Recommended Usage

### Starting a New Project

You can use this repository as a **template** for a new project. If you clone it directly and build on top of it, be aware that your new project will inherit the git ancestry (commit history) of this starter repository. To avoid this, you can either:

- Create a new repository from this template via GitHub (if published as a template), or
- Clone locally, then remove the `.git` directory and run `git init` to start with a clean history:
  ```bash
  git clone git@github.com/cstavro/opencode-starter my-new-project
  cd my-new-project
  rm -rf .git
  git init
  git add .
  git commit -m "Initial commit from opencode-starter"
  ```

### Adding to an Existing Project

If you already have a project and want to add opencode devcontainer support, you can **patch** the relevant files into your existing repository:

- Copy the `.devcontainer/` directory into your project root.
- Adjust `devcontainer.json` and the lifecycle scripts as needed to fit your project's existing setup (for example, merging `features` or `postCreateCommand` with existing values).
- Optionally commit the `.devcontainer/` directory to version control so the environment is reproducible for all contributors.

---

## Per-Devcontainer Configuration via Volume Mount

The devcontainer mounts a Docker volume named `opencode-workspace` at `/mnt/opencode-workspace` inside the container. This volume persists opencode data (such as conversation history, configuration, and state) across container rebuilds.

To keep each project's data separate, the startup scripts compute a unique directory inside the volume based on the **host's project path** (`${localWorkspaceFolder}`). The host path is sanitized (slashes and colons replaced with underscores) and used as a subfolder under `/mnt/opencode-workspace`. This ensures that if you open the same project on different hosts or in different locations, each instance gets its own isolated opencode data directory.

Symbolic links are then created inside the container's home directory so that opencode reads from and writes to the volume-mounted location transparently:

- `~/.local/share/opencode` → `/mnt/opencode-workspace/<sanitized_host_path>/.local/share/opencode`
- `~/.config/opencode` → `/mnt/opencode-workspace/<sanitized_host_path>/.config/opencode`

---

## Customizing `opencode.json`

A default opencode configuration file is bundled in this repository at:

```
.devcontainer/data/.config/opencode/opencode.json
```

When the devcontainer is created for the first time (or whenever the per-project config directory is empty), this default `opencode.json` is automatically copied into the volume-mounted configuration directory. You can edit the file inside `.devcontainer/data/.config/opencode/` **before** building the devcontainer to change the initial settings, or modify `~/.config/opencode/opencode.json` from within the running container to adjust settings afterward.

The bundled default is intentionally minimal:

```json
{
  "$schema": "https://opencode.ai/config.json"
}
```

Add any opencode-specific settings you need to this file.

---

## Post-Create Lifecycle Scripts

After the devcontainer is created, the main entrypoint script at `.devcontainer/lifecycle-scripts/post-create.sh` runs automatically. It scans `.devcontainer/lifecycle-scripts/post-create/` for executable shell scripts (`.sh`) and runs them in sorted order.

### Disabling a Script

To prevent a script from running, prefix its filename with an underscore (`_`). For example, renaming `01-setup-opencode.sh` to `_01-setup-opencode.sh` will cause the orchestrator to skip it.

### Included Scripts

| Script | Purpose |
|--------|---------|
| `00-install-opencode.sh` | Installs the latest opencode CLI via the official installer. |
| `01-setup-opencode.sh` | Sets up the per-project volume mount, creates necessary directories, symlinks opencode data/config folders, and copies the default `opencode.json` if needed. |

You can add your own scripts to `.devcontainer/lifecycle-scripts/post-create/`; they will be picked up automatically as long as they are executable `.sh` files and do not start with an underscore.
