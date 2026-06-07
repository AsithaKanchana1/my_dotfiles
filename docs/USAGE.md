# Usage Guide

## Standard Workflow

### 1. Backup current dotfiles

```bash
./scripts/backup-dotfiles.sh --clean
```

### 2. Install packages

Launch the interactive software selector:

```bash
./scripts/install-software.sh
```

Install specific categories directly (non-interactive):

```bash
./scripts/install-software.sh --categories core,development,desktop
```

Install all categories at once:

```bash
./scripts/install-software.sh --all
```

### 3. Apply dotfiles to a machine

```bash
./scripts/apply-dotfiles.sh
```

---

## Updating Tracked Dotfiles

1. Edit the relevant manifest:
   - `manifests/home-paths.txt` — files under `$HOME`
   - `manifests/config-paths.txt` — directories/files under `$HOME/.config`

2. Re-run a clean backup to sync the repo:

```bash
./scripts/backup-dotfiles.sh --clean
```

3. Commit the resulting updates:

```bash
git add .
git commit -m "Update dotfiles backup"
git push
```

---

## Neovim Setup (VS Code Style)

```bash
./scripts/setup-neovim-vscode.sh
```

**Behavior:**
- Installs Neovim dependencies via `yay` unless skipped.
- Applies repo config from `dotfiles/config/nvim` to `$HOME/.config/nvim`.
- Syncs plugins (lazy.nvim) and installs Mason language tools.

**Optional flags:**

```bash
./scripts/setup-neovim-vscode.sh --skip-packages   # Skip yay installs
./scripts/setup-neovim-vscode.sh --skip-sync       # Skip plugin/LSP sync
```

---

## Neovim Keybindings

Leader key: `Space`

### Explorer and Navigation

| Keys | Action |
|------|--------|
| `Space` + `e` | Toggle right-side file explorer |
| `Space` + `f` + `f` | Find files |
| `Space` + `f` + `g` | Search text in project |
| `Space` + `f` + `b` | List open buffers |

### LSP Actions

| Keys | Action |
|------|--------|
| `K` | Hover documentation |
| `g` + `d` | Go to definition |
| `g` + `r` | Find references |
| `Space` + `r` + `n` | Rename symbol |
| `Space` + `c` + `a` | Code action |

### Completion (Insert Mode)

| Keys | Action |
|------|--------|
| `Ctrl` + `Space` | Open completion menu |
| `Enter` | Confirm selected item |
| `Tab` | Next item or snippet jump forward |
| `Shift` + `Tab` | Previous item or snippet jump back |

---

## Waybar

Waybar is launched automatically by Hyprland on startup. To reload it after config changes:

```bash
killall waybar && waybar &
```

Or use the keybind (set in `hyprland.conf`):

```
Super + Shift + B
```
