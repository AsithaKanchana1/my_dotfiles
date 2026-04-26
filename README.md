# 🐧 Arch Linux Dotfiles

> Reliable, repeatable, and interactive Arch Linux environment management.

A comprehensive, script-driven ecosystem for bootstrapping new Arch Linux installations, managing your software stack interactively, and keeping your configuration files perfectly synchronized across machines.

---

## ✨ Core Features

- **Manifest-Driven Synchronization**: Backup and apply only the files you explicitly track via clean configuration manifests.
- **Interactive Software Catalog**: Browse, categorize, and install software (including proprietary drivers and development tools) through an interactive TTY menu.
- **Automated Drive Mounting**: Safe auto-mounting support for your partitions with preview (`dry-run`) capabilities.
- **Neovim Bootstrapping**: Automatically configure Neovim with an optimized, VS Code-like setup for immediate productivity.
- **Reproducibility**: Script-first workflows designed for zero-hassle environment portability.

---

## 🚀 Quick Start (Bootstrap)

To instantly clone this repository and launch the interactive manager on a new machine, run the following one-liner in your terminal:

**Bash / Zsh / Fish:**
```bash
curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh | bash
```
> **Note**: The bootstrap script supports `curl | bash` interactive usage by automatically reattaching to `/dev/tty` when available, ensuring the menu works smoothly.

---

## 🛠️ Usage & Common Workflows

You can manage your entire setup either through the interactive menu or by calling specific scripts directly.

### 1. The Interactive Manager
The recommended way to manage your system is via the central manager menu.
```bash
./scripts/dotfiles-manager.sh
```
**Controls**:
- `↑` / `↓` or `j` / `k`: Move selection
- `Enter`: Run the selected action
- `q`: Quit menu
- `1-16`: Jump directly to an action number

### 2. Software Installation
Install software and drivers from curated, categorized lists.
```bash
# Launch the interactive software selector
./scripts/install-software.sh

# Or install specific categories directly (non-interactive)
./scripts/install-software.sh --categories core,development,desktop
```

### 3. Dotfiles Synchronization
Backup your current system configurations to the repository, or apply the repository configurations to your machine.

**Backup to Repository:**
```bash
# Backup both home and config paths, removing stale tracking files first
./scripts/backup-dotfiles.sh --clean
```

**Apply to System:**
```bash
# Apply tracked dotfiles, replacing existing files in $HOME and $HOME/.config
./scripts/apply-dotfiles.sh
```

### 4. Auto-Mounting Drives
Easily mount eligible secondary drives using `udisksctl`.
```bash
# Preview what would be mounted (Dry Run)
./scripts/auto-mount-drives.sh --dry-run

# Actually mount the drives
./scripts/auto-mount-drives.sh
```

---

## 📁 Repository Structure

### Scripts & Automation
| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | Clone or update from GitHub and launch the manager. |
| `dotfiles-manager.sh` | Central interactive TTY runner for all scripts. |
| `install-software.sh` | Interactively install categorized software and drivers. |
| `apply-dotfiles.sh` | Wrapper to apply both home and config dotfiles. |
| `backup-dotfiles.sh` | Wrapper to backup both home and config dotfiles. |
| `auto-mount-drives.sh` | Auto-mount eligible partitions. |
| `setup-neovim-vscode.sh`| Configure Neovim with VS Code-like behavior. |
| `check-manifest-paths.sh`| Validate manifest entries against the current system. |

### Configuration & Data
| Path | Purpose |
|------|---------|
| `packages/catalog/` | Contains categorized software and driver lists (`core.txt`, `media.txt`, etc.). |
| `manifests/home-paths.txt`| Specific paths under `$HOME` to track and backup. |
| `manifests/config-paths.txt`| Specific paths under `$HOME/.config` to track and backup. |
| `dotfiles/home/` | The actual versioned home dotfiles. |
| `dotfiles/config/` | The actual versioned config dotfiles. |

---

## ⚙️ Advanced: Non-Interactive Automation

The `bootstrap.sh` and `dotfiles-manager.sh` scripts support direct command execution for CI/CD or headless automation:

```bash
# Run a specific command by name
./scripts/dotfiles-manager.sh backup-all-clean
./scripts/dotfiles-manager.sh apply-all

# Run a specific menu action by number
./scripts/dotfiles-manager.sh --action 10

# Through the bootstrap script
curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh | bash -s -- --command check-paths
```

---

## 📝 Operational Notes

- **Customizing Tracked Paths**: To track a new dotfile, simply add its path to the respective manifest (`manifests/home-paths.txt` or `manifests/config-paths.txt`), then run `./scripts/backup-dotfiles.sh --clean`.
- **Applying Overwrites**: Applying dotfiles will **overwrite** existing files on the target machine when paths overlap.
- **Git Version Control**: Always review your repository changes (`git status`, `git diff`) before committing backups.
