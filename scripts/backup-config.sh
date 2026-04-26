#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_MANIFEST="$REPO_ROOT/manifests/config-paths.txt"
DEST_CONFIG="$REPO_ROOT/dotfiles/config"
CLEAN_DEST=0

for arg in "$@"; do
  case "$arg" in
    --clean)
      CLEAN_DEST=1
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--clean]" >&2
      exit 1
      ;;
  esac
done

mkdir -p "$DEST_CONFIG"

if [[ "$CLEAN_DEST" -eq 1 ]]; then
  rm -rf "$DEST_CONFIG"/*
fi

copy_path() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    echo "Skipping missing path: $src"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -a "$src" "$dest"
  echo "Backed up: $src -> $dest"
}

while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "$rel" || "$rel" =~ ^[[:space:]]*# ]] && continue
  copy_path "$HOME/.config/$rel" "$DEST_CONFIG/$rel"
done < "$CONFIG_MANIFEST"

echo "Config backup complete."