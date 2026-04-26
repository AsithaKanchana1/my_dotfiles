#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_MANIFEST="$REPO_ROOT/manifests/config-paths.txt"
SRC_CONFIG="$REPO_ROOT/dotfiles/config"

mkdir -p "$HOME/.config"

copy_path() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    echo "Skipping missing repo path: $src"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -a "$src" "$dest"
  echo "Applied config: $dest"
}

while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "$rel" || "$rel" =~ ^[[:space:]]*# ]] && continue
  copy_path "$SRC_CONFIG/$rel" "$HOME/.config/$rel"
done < "$CONFIG_MANIFEST"

echo "Config dotfiles applied."