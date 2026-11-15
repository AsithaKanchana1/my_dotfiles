#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DEST_CONFIG="$REPO_ROOT/dotfiles/config"
DEST_HOME="$REPO_ROOT/dotfiles/home"
DEST_PACKAGES="$REPO_ROOT/packages"

CONFIG_DIRS=(
  alacritty
  btop
  cachyos
  crossnote
  fastfetch
  glib-2.0
  gtk-3.0
  gtk-4.0
  htop
  hypr
  kitty
  menus
  noctalia
  qt5ct
  qt6ct
  rofi
  satty
  vlc
  waybar
  wofi
  xsettingsd
  yazi
)

CONFIG_FILES=(
  baloofileinformationrc
  cachyos-hello.json
  cpak-mimeapps.list
  dolphinrc
  kdeglobals
  mimeapps.list
  pavucontrol.ini
  QtProject.conf
  topgrade.toml
  user-dirs.dirs
  user-dirs.locale
)

HOME_FILES=(
  .bash_logout
  .bash_profile
  .bashrc
  .gitconfig
  .gitconfig.cachyos
  .wakatime.cfg
  .zshrc
)

COMMON_EXCLUDES=(
  --exclude='__pycache__/'
  --exclude='*.pyc'
  --exclude='*.bak'
  --exclude='*.bak.*'
  --exclude='*.log'
  --exclude='*.tmp'
  --exclude='.DS_Store'
)

copy_dir() {
  local name="$1"
  shift
  local src="$SRC_CONFIG/$name"
  local dest="$DEST_CONFIG/$name"
  [[ -d "$src" ]] || return 0
  mkdir -p "$dest"
  rsync -a --delete --delete-excluded "${COMMON_EXCLUDES[@]}" "$@" "$src/" "$dest/"
}

copy_file() {
  local name="$1"
  [[ -f "$SRC_CONFIG/$name" ]] || return 0
  cp -a "$SRC_CONFIG/$name" "$DEST_CONFIG/$name"
}

mkdir -p "$DEST_CONFIG" "$DEST_HOME" "$DEST_PACKAGES"

for dir in "${CONFIG_DIRS[@]}"; do
  copy_dir "$dir"
done

copy_dir fish --exclude='fish_variables'
copy_dir hypr --exclude='hyprland.conf.bak.*' --exclude='hyprland.lua.bak'
copy_dir nvim --exclude='doc' --exclude='plugin_backup'

for file in "${CONFIG_FILES[@]}"; do
  copy_file "$file"
done

mkdir -p "$DEST_CONFIG/micro/colorschemes"
[[ -f "$SRC_CONFIG/micro/settings.json" ]] && cp -a "$SRC_CONFIG/micro/settings.json" "$DEST_CONFIG/micro/"
if [[ -d "$SRC_CONFIG/micro/colorschemes" ]]; then
  rsync -a --delete "$SRC_CONFIG/micro/colorschemes/" "$DEST_CONFIG/micro/colorschemes/"
fi

mkdir -p "$DEST_CONFIG/Code/User"
for file in settings.json keybindings.json mcp.json chatLanguageModels.json; do
  [[ -f "$SRC_CONFIG/Code/User/$file" ]] && cp -a "$SRC_CONFIG/Code/User/$file" "$DEST_CONFIG/Code/User/$file"
done

mkdir -p "$DEST_CONFIG/opencode"
for file in opencode.jsonc package.json package-lock.json; do
  [[ -f "$SRC_CONFIG/opencode/$file" ]] && cp -a "$SRC_CONFIG/opencode/$file" "$DEST_CONFIG/opencode/$file"
done

mkdir -p "$DEST_CONFIG/gh"
[[ -f "$SRC_CONFIG/gh/config.yml" ]] && cp -a "$SRC_CONFIG/gh/config.yml" "$DEST_CONFIG/gh/config.yml"

for file in "${HOME_FILES[@]}"; do
  [[ -f "$HOME/$file" ]] && cp -a "$HOME/$file" "$DEST_HOME/$file"
done

if [[ -f "$DEST_CONFIG/fish/config.fish" ]]; then
  sed -i -E 's/^(set -gx ANTHROPIC_AUTH_TOKEN ).*$/\1"REDACTED_ADD_YOUR_KEY_HERE"/' "$DEST_CONFIG/fish/config.fish"
fi

if command -v pacman >/dev/null 2>&1; then
  pacman -Qqe >"$DEST_PACKAGES/pacman-explicit.txt"
  pacman -Qqem >"$DEST_PACKAGES/pacman-aur.txt"
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user list-unit-files --state=enabled --no-legend 2>/dev/null \
    | awk '{print $1}' >"$DEST_PACKAGES/systemd-user-units.txt" || true
fi

echo "Backup written to $REPO_ROOT"
echo "Review changes with: git -C \"$REPO_ROOT\" status"
