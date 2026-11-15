#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_CONFIG="$REPO_ROOT/dotfiles/config"
SRC_HOME="$REPO_ROOT/dotfiles/home"
DEST_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$HOME/config-backup-$STAMP"

if [[ ! -d "$SRC_CONFIG" ]]; then
  echo "No backed-up configuration found at $SRC_CONFIG" >&2
  exit 1
fi

echo "Existing files will be backed up to $BACKUP_ROOT"

mkdir -p "$DEST_CONFIG" "$BACKUP_ROOT/config" "$BACKUP_ROOT/home"

for src in "$SRC_CONFIG"/*; do
  name="$(basename "$src")"
  if [[ -d "$src" ]]; then
    if [[ -d "$DEST_CONFIG/$name" ]]; then
      mkdir -p "$BACKUP_ROOT/config/$name"
      rsync -a "$DEST_CONFIG/$name/" "$BACKUP_ROOT/config/$name/"
    fi
    mkdir -p "$DEST_CONFIG/$name"
    rsync -a "$src/" "$DEST_CONFIG/$name/"
  elif [[ -f "$src" ]]; then
    [[ -f "$DEST_CONFIG/$name" ]] && cp -a "$DEST_CONFIG/$name" "$BACKUP_ROOT/config/$name"
    cp -a "$src" "$DEST_CONFIG/$name"
  fi
done

for src in "$SRC_HOME"/.[!.]*; do
  [[ -f "$src" ]] || continue
  name="$(basename "$src")"
  [[ -f "$HOME/$name" ]] && cp -a "$HOME/$name" "$BACKUP_ROOT/home/$name"
  cp -a "$src" "$HOME/$name"
done

echo "Configuration restored."
echo "Note: dotfiles/config/fish/config.fish stores a redacted API token."
echo "      Set ANTHROPIC_AUTH_TOKEN in fish/config.fish before using OmniRoute."
echo "Reload Hyprland and Waybar with: hyprctl reload && pkill -x waybar; waybar >/tmp/waybar.log 2>&1 &"
