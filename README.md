# Arch Dotfiles

A clean, repeatable Arch setup with:

- Package installation (base + optional extended set)
- Dotfile backup from the current system into this repo
- Dotfile apply workflow to restore your setup on another machine

## Repository Layout

- `scripts/install-packages.sh`: Installs packages from lists in `packages/`
- `scripts/install-base-packages.sh`: Installs only base package set
- `scripts/install-extended-packages.sh`: Installs base + extended package sets
- `scripts/backup-home.sh`: Backs up paths listed in `manifests/home-paths.txt`
- `scripts/backup-config.sh`: Backs up paths listed in `manifests/config-paths.txt`
- `scripts/backup-dotfiles.sh`: Runs home + config backups together
- `scripts/apply-home.sh`: Applies tracked home dotfiles only
- `scripts/apply-config.sh`: Applies tracked config dotfiles only
- `scripts/apply-dotfiles.sh`: Runs home + config apply together
- `scripts/auto-mount-drives.sh`: Auto-mounts eligible disk partitions via `udisksctl`
- `scripts/check-manifest-paths.sh`: Shows which manifest paths exist/missing on current system
- `scripts/dotfiles-manager.sh`: Master script (interactive menu + command mode)
- `scripts/bootstrap.sh`: Clone/update from GitHub and run manager
- `packages/base-packages.txt`: Core package list
- `packages/extended-packages.txt`: Optional package list
- `manifests/home-paths.txt`: Dotfiles from `$HOME` to track
- `manifests/config-paths.txt`: Paths from `$HOME/.config` to track
- `dotfiles/home`: Backed up files from `$HOME`
- `dotfiles/config`: Backed up config entries from `$HOME/.config`

## Quick Start

0. One-line GitHub bootstrap (clone/update + open master menu):

   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh)
   ```

   Direct command mode (example):

   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh) -- --command check-paths
   ```

1. Backup current machine dotfiles into this repository:

   ```bash
   ./scripts/backup-dotfiles.sh --clean
   ```

2. Install packages:

   ```bash
   ./scripts/install-packages.sh
   ```

3. Install base + extended package sets:

   ```bash
   ./scripts/install-packages.sh --extended
   ```

4. Apply backed up dotfiles to current machine:

   ```bash
   ./scripts/apply-dotfiles.sh
   ```

5. Use the master script (interactive):

   ```bash
   ./scripts/dotfiles-manager.sh
   ```

6. Use the master script (direct command):

   ```bash
   ./scripts/dotfiles-manager.sh backup-all-clean
   ./scripts/dotfiles-manager.sh apply-all
   ```

7. Auto-mount available drives (safe mode skips system/root disk partitions):

   ```bash
   ./scripts/auto-mount-drives.sh
   ```

8. Preview what would be mounted without making changes:

   ```bash
   ./scripts/auto-mount-drives.sh --dry-run
   ```

## Master Script Commands

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

## Customize What Gets Backed Up

Edit these files:

- `manifests/home-paths.txt`
- `manifests/config-paths.txt`

Then run:

```bash
./scripts/backup-dotfiles.sh --clean
```

## Notes

- Existing files in `$HOME` and `$HOME/.config` with the same name are replaced by `apply-dotfiles.sh`.
- Use Git to review changes before committing:

```bash
git status
git diff
```
