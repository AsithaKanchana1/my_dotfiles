#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/dotfiles-manager.sh                # interactive menu
  ./scripts/dotfiles-manager.sh --action <N>   # run menu option number
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

run_action_number() {
  local action="$1"

  case "$action" in
    1) run_command backup-all ;;
    2) run_command backup-all-clean ;;
    3) run_command backup-home ;;
    4) run_command backup-home-clean ;;
    5) run_command backup-config ;;
    6) run_command backup-config-clean ;;
    7) run_command apply-all ;;
    8) run_command apply-home ;;
    9) run_command apply-config ;;
    10) run_command install-base ;;
    11) run_command install-extended ;;
    12) run_command auto-mount ;;
    13) run_command auto-mount-dry-run ;;
    14) run_command setup-neovim-vscode ;;
    15) run_command check-paths ;;
    16) echo "Bye." ;;
    *)
      echo "Unknown action number: $action" >&2
      return 1
      ;;
  esac
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
  local items=(
    "Backup all"
    "Backup all (clean)"
    "Backup home"
    "Backup home (clean)"
    "Backup config"
    "Backup config (clean)"
    "Apply all"
    "Apply home"
    "Apply config"
    "Install base packages"
    "Install extended packages"
    "Auto-mount drives"
    "Auto-mount drives (dry-run)"
    "Setup Neovim (VS Code style)"
    "Check manifest paths"
    "Quit"
  )
  local selected=0
  local total="${#items[@]}"
  local key=""
  local i
  local action_number

  while true; do
    printf '\033[H\033[2J'
    echo "Dotfiles Manager"
    echo "----------------"
    echo "Use ↑/↓ (or j/k), Enter to select, q to quit."
    echo

    for ((i = 0; i < total; i++)); do
      if [[ "$i" -eq "$selected" ]]; then
        printf " > %2d) %s\n" "$((i + 1))" "${items[$i]}"
      else
        printf "   %2d) %s\n" "$((i + 1))" "${items[$i]}"
      fi
    done

    IFS= read -rsn1 key || true
    if [[ "$key" == $'\x1b' ]]; then
      # Consume the remaining bytes of escape sequences such as arrow keys.
      IFS= read -rsn2 -t 0.01 key || true
    fi

    case "$key" in
      $'\x1b[A'|k|K)
        selected=$(((selected - 1 + total) % total))
        ;;
      $'\x1b[B'|j|J)
        selected=$(((selected + 1) % total))
        ;;
      $'\n'|$'\r')
        action_number="$((selected + 1))"
        printf '\n'
        run_action_number "$action_number"
        break
        ;;
      q|Q)
        printf '\nBye.\n'
        break
        ;;
      [1-9])
        if (( key <= total )); then
          printf '\n'
          run_action_number "$key"
          break
        fi
        ;;
      1)
        IFS= read -rsn1 -t 0.8 key || key=""
        case "$key" in
          [0-6])
            action_number="1$key"
            printf '\n'
            run_action_number "$action_number"
            break
            ;;
          *)
            ;;
        esac
        ;;
      *)
        ;;
    esac
  done
}

if [[ $# -eq 0 ]]; then
  if [[ ! -t 0 ]]; then
    echo "Interactive menu requires a TTY. Use a command or --action <N>." >&2
    usage
    exit 1
  fi
  show_menu
  exit 0
fi

if [[ "$1" == "--action" ]]; then
  if [[ $# -lt 2 ]]; then
    echo "Missing value for --action" >&2
    usage
    exit 1
  fi
  run_action_number "$2"
  exit 0
fi

if [[ "$1" =~ ^[0-9]+$ ]]; then
  run_action_number "$1"
  exit 0
fi

run_command "$1"
