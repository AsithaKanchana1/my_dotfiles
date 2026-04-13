#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_HOME="$REPO_ROOT/dotfiles/home"
SRC_CONFIG="$REPO_ROOT/dotfiles/config"

mkdir -p "$HOME/.config"

if [[ -d "$SRC_HOME" ]]; then
  find "$SRC_HOME" -mindepth 1 -maxdepth 1 | while IFS= read -r path; do
    name="$(basename "$path")"
    target="$HOME/$name"
    rm -rf "$target"
    cp -a "$path" "$target"
    echo "Applied: $name"
  done
fi

if [[ -d "$SRC_CONFIG" ]]; then
  find "$SRC_CONFIG" -mindepth 1 -maxdepth 1 | while IFS= read -r path; do
    name="$(basename "$path")"
    target="$HOME/.config/$name"
    rm -rf "$target"
    cp -a "$path" "$target"
    echo "Applied config: $name"
  done
fi

echo "Dotfiles applied to HOME."
