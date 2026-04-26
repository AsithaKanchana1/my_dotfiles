#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/AsithaKanchana1/my_dotfiles.git"
DEFAULT_DIR="$HOME/.local/share/my_dotfiles"
BRANCH="main"
TARGET_DIR="$DEFAULT_DIR"
RUN_COMMAND=""
RUN_ACTION=""

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--dir PATH] [--branch NAME] [--command CMD] [--action N]

Options:
  --dir PATH      Clone/update into PATH (default: ~/.local/share/my_dotfiles)
  --branch NAME   Git branch to use (default: main)
  --command CMD   Run a manager command directly (example: apply-all)
  --action N      Run a manager menu item by number (example: 7 for "Apply all")
  -h, --help      Show help

Examples:
  bootstrap.sh
  bootstrap.sh --command check-paths
  bootstrap.sh --action 15
  bootstrap.sh --dir "$HOME/my_dotfiles"
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --branch)
      BRANCH="${2:-}"
      shift 2
      ;;
    --command)
      RUN_COMMAND="${2:-}"
      shift 2
      ;;
    --action)
      RUN_ACTION="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required for bootstrap." >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET_DIR")"

if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "Updating existing repo in: $TARGET_DIR"
  git -C "$TARGET_DIR" fetch origin
  git -C "$TARGET_DIR" checkout "$BRANCH"
  git -C "$TARGET_DIR" pull --ff-only origin "$BRANCH"
else
  if [[ -e "$TARGET_DIR" && ! -d "$TARGET_DIR/.git" ]]; then
    echo "Error: target exists but is not a git repo: $TARGET_DIR" >&2
    exit 1
  fi

  echo "Cloning repo into: $TARGET_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

chmod +x "$TARGET_DIR"/scripts/*.sh

if [[ -n "$RUN_COMMAND" ]]; then
  exec "$TARGET_DIR/scripts/dotfiles-manager.sh" "$RUN_COMMAND"
elif [[ -n "$RUN_ACTION" ]]; then
  exec "$TARGET_DIR/scripts/dotfiles-manager.sh" --action "$RUN_ACTION"
elif [[ ! -t 0 && -r /dev/tty ]]; then
  # When bootstrap is piped (e.g. curl | bash), stdin is not interactive.
  # Reattach stdin to the user's terminal so the menu can still be used.
  exec "$TARGET_DIR/scripts/dotfiles-manager.sh" </dev/tty
elif [[ ! -t 0 ]]; then
  echo "No interactive terminal detected, so the menu cannot read a selection." >&2
  echo "Run bootstrap with --command or --action, for example:" >&2
  echo "  curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh | bash -s -- --action 7" >&2
  echo "  curl -fsSL https://raw.githubusercontent.com/AsithaKanchana1/my_dotfiles/main/scripts/bootstrap.sh | bash -s -- --command apply-all" >&2
  exit 1
else
  exec "$TARGET_DIR/scripts/dotfiles-manager.sh"
fi
