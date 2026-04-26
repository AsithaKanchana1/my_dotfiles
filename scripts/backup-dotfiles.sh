#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [--clean]" >&2
  exit 1
fi

if [[ $# -eq 1 && "$1" != "--clean" ]]; then
  echo "Unknown argument: $1" >&2
  echo "Usage: $0 [--clean]" >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then
  "$SCRIPT_DIR/backup-home.sh" --clean
  "$SCRIPT_DIR/backup-config.sh" --clean
else
  "$SCRIPT_DIR/backup-home.sh"
  "$SCRIPT_DIR/backup-config.sh"
fi

echo "Dotfile backup complete."
