# Arch Dotfiles

Reliable, repeatable Arch Linux dotfile management with:

- Package installation from curated lists
- Backup of selected home and config paths
- Apply workflow for restoring the same setup on another machine
- Optional Neovim bootstrap with VS Code-style ergonomics

## Core Features

- Manifest-driven backup and restore
- Script-first workflow for automation and reproducibility
- Interactive manager for day-to-day operations
- Safe drive auto-mount support with dry-run mode

## Project Structure

- `scripts/install-packages.sh`: Install packages from list files in `packages/`
- `scripts/install-base-packages.sh`: Install only base packages
- `scripts/install-extended-packages.sh`: Install base and extended packages
- `scripts/backup-home.sh`: Backup paths listed in `manifests/home-paths.txt`
- `scripts/backup-config.sh`: Backup paths listed in `manifests/config-paths.txt`
- `scripts/backup-dotfiles.sh`: Run home and config backups together
- `scripts/apply-home.sh`: Apply tracked home dotfiles
- `scripts/apply-config.sh`: Apply tracked config dotfiles
- `scripts/apply-dotfiles.sh`: Run home and config apply together
- `scripts/auto-mount-drives.sh`: Auto-mount eligible partitions via `udisksctl`
- `scripts/check-manifest-paths.sh`: Validate manifest entries against the current system
- `scripts/setup-neovim-vscode.sh`: Configure Neovim with VS Code-like behavior and language tooling
- `scripts/dotfiles-manager.sh`: Central command runner with menu and direct modes
- `scripts/bootstrap.sh`: Clone or update from GitHub and launch manager
- `packages/base-packages.txt`: Base package catalog
- `packages/extended-packages.txt`: Optional package catalog
- `manifests/home-paths.txt`: Paths under `$HOME` to track
- `manifests/config-paths.txt`: Paths under `$HOME/.config` to track
- `dotfiles/home`: Versioned home dotfiles
- `dotfiles/config`: Versioned config dotfiles

## Quick Start

1. Bootstrap from GitHub and open the manager menu.

Bash/Zsh:

```bash
curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh | bash
```

Fish:

```fish
curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh | bash
```

1. Run a direct command through bootstrap (example).

Bash/Zsh:

```bash
curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh | bash -s -- --command check-paths
```

Fish:

```fish
curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh | bash -s -- --command check-paths
```

1. Backup current dotfiles into the repository.

```bash
./scripts/backup-dotfiles.sh --clean
```

1. Install base packages.

```bash
./scripts/install-packages.sh
```

1. Install base and extended packages.

```bash
./scripts/install-packages.sh --extended
```

1. Apply tracked dotfiles to the current machine.

```bash
./scripts/apply-dotfiles.sh
```

1. Run the manager in interactive mode.

```bash
./scripts/dotfiles-manager.sh
```

1. Run manager commands directly.

```bash
./scripts/dotfiles-manager.sh backup-all-clean
./scripts/dotfiles-manager.sh apply-all
```

1. Auto-mount available drives.

```bash
./scripts/auto-mount-drives.sh
```

1. Preview mount actions without making changes.

```bash
./scripts/auto-mount-drives.sh --dry-run
```

## Dotfiles Manager Commands

- `backup-all`
- `backup-all-clean`
- `backup-home`
- `backup-home-clean`
- `backup-config`
- `backup-config-clean`
- `apply-all`
- `apply-home`
- `apply-config`
- `install-base`
- `install-extended`
- `auto-mount`
- `auto-mount-dry-run`
- `check-paths`
- `setup-neovim-vscode`

## Customizing Tracked Paths

Update the manifests, then run a clean backup.

- `manifests/home-paths.txt`
- `manifests/config-paths.txt`

```bash
./scripts/backup-dotfiles.sh --clean
```

## Operational Notes

- Applying dotfiles replaces existing files in `$HOME` and `$HOME/.config` when paths overlap.
- Review repository changes before committing.

```bash
git status
git diff
```
