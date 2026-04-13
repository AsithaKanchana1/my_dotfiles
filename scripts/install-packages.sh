#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE_LIST="$REPO_ROOT/packages/base-packages.txt"
EXTENDED_LIST="$REPO_ROOT/packages/extended-packages.txt"
INSTALL_EXTENDED=0

for arg in "$@"; do
  case "$arg" in
    --extended)
      INSTALL_EXTENDED=1
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 [--extended]"
      exit 1
      ;;
  esac
done

install_yay_if_missing() {
  if command -v yay >/dev/null 2>&1; then
    return
  fi

  echo "Yay not found. Installing..."
  sudo pacman -S --needed base-devel git --noconfirm
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  pushd /tmp/yay >/dev/null
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf /tmp/yay
}

read_package_file() {
  local file="$1"
  mapfile -t PKGS < <(grep -vE '^\s*$|^\s*#' "$file")
}

install_yay_if_missing

read_package_file "$BASE_LIST"
if ((${#PKGS[@]} > 0)); then
  echo "Installing base packages..."
  yay -S --noconfirm --needed "${PKGS[@]}"
fi

if [[ "$INSTALL_EXTENDED" -eq 1 ]]; then
  read_package_file "$EXTENDED_LIST"
  if ((${#PKGS[@]} > 0)); then
    echo "Installing extended packages..."
    yay -S --noconfirm --needed "${PKGS[@]}"
  fi
fi

if command -v rustup >/dev/null 2>&1; then
  rustup default stable
fi

echo "Package installation complete."
