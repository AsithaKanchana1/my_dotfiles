#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOME_MANIFEST="$REPO_ROOT/manifests/home-paths.txt"
CONFIG_MANIFEST="$REPO_ROOT/manifests/config-paths.txt"
DEST_HOME="$REPO_ROOT/dotfiles/home"
DEST_CONFIG="$REPO_ROOT/dotfiles/config"

clean_dest=0

for arg in "$@"; do
  case "$arg" in
    --clean)
      clean_dest=1
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 [--clean]"
      exit 1
      ;;
  esac
done

mkdir -p "$DEST_HOME" "$DEST_CONFIG"

if [[ "$clean_dest" -eq 1 ]]; then
  rm -rf "$DEST_HOME"/* "$DEST_CONFIG"/*
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
  copy_path "$HOME/$rel" "$DEST_HOME/$rel"
done < "$HOME_MANIFEST"

while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "$rel" || "$rel" =~ ^[[:space:]]*# ]] && continue
  copy_path "$HOME/.config/$rel" "$DEST_CONFIG/$rel"
done < "$CONFIG_MANIFEST"

echo "Dotfile backup complete."
