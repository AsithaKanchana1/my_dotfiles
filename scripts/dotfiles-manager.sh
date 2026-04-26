#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/dotfiles-manager.sh                # interactive menu
  ./scripts/dotfiles-manager.sh <command>

Commands:
  backup-all
  backup-all-clean
  backup-home
  backup-home-clean
  backup-config
  backup-config-clean
  apply-all
  apply-home
  apply-config
  install-base
  install-extended
  auto-mount
  auto-mount-dry-run
  setup-neovim-vscode
  check-paths
  help
EOF
}

run_command() {
  local cmd="$1"
  case "$cmd" in
    backup-all)
      "$SCRIPT_DIR/backup-home.sh"
      "$SCRIPT_DIR/backup-config.sh"
      ;;
    backup-all-clean)
      "$SCRIPT_DIR/backup-home.sh" --clean
      "$SCRIPT_DIR/backup-config.sh" --clean
      ;;
    backup-home)
      "$SCRIPT_DIR/backup-home.sh"
      ;;
    backup-home-clean)
      "$SCRIPT_DIR/backup-home.sh" --clean
      ;;
    backup-config)
      "$SCRIPT_DIR/backup-config.sh"
      ;;
    backup-config-clean)
      "$SCRIPT_DIR/backup-config.sh" --clean
      ;;
    apply-all)
      "$SCRIPT_DIR/apply-home.sh"
      "$SCRIPT_DIR/apply-config.sh"
      ;;
    apply-home)
      "$SCRIPT_DIR/apply-home.sh"
      ;;
    apply-config)
      "$SCRIPT_DIR/apply-config.sh"
      ;;
    install-base)
      "$SCRIPT_DIR/install-base-packages.sh"
      ;;
    install-extended)
      "$SCRIPT_DIR/install-extended-packages.sh"
      ;;
    auto-mount)
      "$SCRIPT_DIR/auto-mount-drives.sh"
      ;;
    auto-mount-dry-run)
      "$SCRIPT_DIR/auto-mount-drives.sh" --dry-run
      ;;
    setup-neovim-vscode)
      "$SCRIPT_DIR/setup-neovim-vscode.sh"
      ;;
    check-paths)
      "$SCRIPT_DIR/check-manifest-paths.sh"
      ;;
    help)
      usage
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage
      return 1
      ;;
  esac
}

show_menu() {
  echo "Dotfiles Manager"
  echo "----------------"

  PS3="Select an action (number): "
  select choice in \
    "Backup all" \
    "Backup all (clean)" \
    "Backup home" \
    "Backup home (clean)" \
    "Backup config" \
    "Backup config (clean)" \
    "Apply all" \
    "Apply home" \
    "Apply config" \
    "Install base packages" \
    "Install extended packages" \
    "Auto-mount drives" \
    "Auto-mount drives (dry-run)" \
    "Setup Neovim (VS Code style)" \
    "Check manifest paths" \
    "Quit"; do
    case "$REPLY" in
      1) run_command backup-all; break ;;
      2) run_command backup-all-clean; break ;;
      3) run_command backup-home; break ;;
      4) run_command backup-home-clean; break ;;
      5) run_command backup-config; break ;;
      6) run_command backup-config-clean; break ;;
      7) run_command apply-all; break ;;
      8) run_command apply-home; break ;;
      9) run_command apply-config; break ;;
      10) run_command install-base; break ;;
      11) run_command install-extended; break ;;
      12) run_command auto-mount; break ;;
      13) run_command auto-mount-dry-run; break ;;
      14) run_command setup-neovim-vscode; break ;;
      15) run_command check-paths; break ;;
      16) echo "Bye."; break ;;
      *) echo "Invalid selection." ;;
    esac
  done
}

if [[ $# -eq 0 ]]; then
  show_menu
  exit 0
fi

run_command "$1"