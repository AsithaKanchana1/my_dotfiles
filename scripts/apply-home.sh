#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOME_MANIFEST="$REPO_ROOT/manifests/home-paths.txt"
SRC_HOME="$REPO_ROOT/dotfiles/home"

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
  echo "Applied: $dest"
}

while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "$rel" || "$rel" =~ ^[[:space:]]*# ]] && continue
  copy_path "$SRC_HOME/$rel" "$HOME/$rel"
done < "$HOME_MANIFEST"

echo "Home dotfiles applied."