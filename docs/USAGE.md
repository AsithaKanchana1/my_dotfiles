# Usage Guide

## Standard Workflow

1. Backup current dotfiles.

```bash
./scripts/backup-dotfiles.sh --clean
```

1. Install packages.

Base packages:

```bash
./scripts/install-packages.sh
```

Base and extended packages:

```bash
./scripts/install-packages.sh --extended
```

1. Apply dotfiles to a machine.

```bash
./scripts/apply-dotfiles.sh
```

## Updating Tracked Dotfiles

1. Edit manifests.

- `manifests/home-paths.txt`
- `manifests/config-paths.txt`

1. Re-run clean backup.

```bash
./scripts/backup-dotfiles.sh --clean
```

1. Commit the resulting updates.

```bash
git add .
git commit -m "Update dotfiles backup"
```

## Neovim Setup (VS Code Style)

Run:

```bash
./scripts/setup-neovim-vscode.sh
```

Behavior:

- Installs Neovim dependencies unless skipped
- Applies repo config from `dotfiles/config/nvim` to `$HOME/.config/nvim`
- Syncs plugins and Mason language tools

Optional flags:

```bash
./scripts/setup-neovim-vscode.sh --skip-packages
./scripts/setup-neovim-vscode.sh --skip-sync
```

## Neovim Keybindings

Leader key: Space

Explorer and navigation:

- Space + e: Toggle right-side explorer
- Space + f + f: Find files
- Space + f + g: Search text in project
- Space + f + b: List open buffers

LSP actions:

- K: Hover documentation
- g + d: Go to definition
- g + r: Find references
- Space + r + n: Rename symbol
- Space + c + a: Code action

Completion in insert mode:

- Ctrl + Space: Open completion menu
- Enter: Confirm selected item
- Tab: Next completion item or snippet jump
- Shift + Tab: Previous completion item or snippet jump back
