#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_NVIM_DIR="$REPO_ROOT/dotfiles/config/nvim"
TARGET_NVIM_DIR="$HOME/.config/nvim"

SKIP_PACKAGES=0
SKIP_SYNC=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/setup-neovim-vscode.sh [--skip-packages] [--skip-sync]

Options:
  --skip-packages    Skip package installation via yay
  --skip-sync        Skip headless plugin and Mason sync
EOF
}

for arg in "$@"; do
  case "$arg" in
    --skip-packages)
      SKIP_PACKAGES=1
      ;;
    --skip-sync)
      SKIP_SYNC=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage
      exit 1
      ;;
  esac
done

install_yay_if_missing() {
  if command -v yay >/dev/null 2>&1; then
    return
  fi

  echo "yay is missing. Installing yay..."
  sudo pacman -S --needed base-devel git --noconfirm
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  pushd /tmp/yay >/dev/null
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf /tmp/yay
}

install_dependencies() {
  local pkgs=(
    neovim
    git
    curl
    unzip
    ripgrep
    fd
    nodejs
    npm
    python
    python-pip
    rustup
    jdk-openjdk
  )

  install_yay_if_missing
  echo "Installing Neovim dependencies..."
  yay -S --noconfirm --needed "${pkgs[@]}"
}

apply_repo_nvim_config() {
  if [[ ! -d "$REPO_NVIM_DIR" ]]; then
    echo "Missing repo Neovim config: $REPO_NVIM_DIR" >&2
    exit 1
  fi

  mkdir -p "$HOME/.config"

  if [[ -d "$TARGET_NVIM_DIR" && ! -L "$TARGET_NVIM_DIR" ]]; then
    local backup_dir="${TARGET_NVIM_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
    mv "$TARGET_NVIM_DIR" "$backup_dir"
    echo "Backed up existing Neovim config to: $backup_dir"
  fi

  rm -rf "$TARGET_NVIM_DIR"
  cp -a "$REPO_NVIM_DIR" "$TARGET_NVIM_DIR"
  echo "Applied Neovim config: $TARGET_NVIM_DIR"
}

sync_neovim() {
  if ! command -v nvim >/dev/null 2>&1; then
    echo "Neovim is not installed. Cannot sync plugins." >&2
    exit 1
  fi

  echo "Syncing plugins with lazy.nvim..."
  nvim --headless "+Lazy! sync" +qa

  echo "Installing Mason LSP servers..."
  nvim --headless "+MasonInstall bash-language-server css-lsp html-lsp jdtls json-lsp lua-language-server marksman pyright rust-analyzer sqlls typescript-language-server yaml-language-server" +qa || true
}

if [[ "$SKIP_PACKAGES" -eq 0 ]]; then
  install_dependencies
else
  echo "Skipping package installation (--skip-packages)."
fi

apply_repo_nvim_config

if [[ "$SKIP_SYNC" -eq 0 ]]; then
  sync_neovim
else
  echo "Skipping plugin/LSP sync (--skip-sync)."
fi

echo "Done. Open Neovim and use <leader>e for the right-side explorer."
