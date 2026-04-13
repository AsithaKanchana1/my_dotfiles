# Arch Dotfiles

A clean, repeatable Arch setup with:

- Package installation (base + optional extended set)
- Dotfile backup from the current system into this repo
- Dotfile apply workflow to restore your setup on another machine

## Repository Layout

- `scripts/install-packages.sh`: Installs packages from lists in `packages/`
- `scripts/backup-dotfiles.sh`: Copies selected current dotfiles into `dotfiles/`
- `scripts/apply-dotfiles.sh`: Applies tracked dotfiles from this repo to `$HOME`
- `packages/base-packages.txt`: Core package list
- `packages/extended-packages.txt`: Optional package list
- `manifests/home-paths.txt`: Dotfiles from `$HOME` to track
- `manifests/config-paths.txt`: Paths from `$HOME/.config` to track
- `dotfiles/home`: Backed up files from `$HOME`
- `dotfiles/config`: Backed up config entries from `$HOME/.config`

## Quick Start

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
