#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOME_MANIFEST="$REPO_ROOT/manifests/home-paths.txt"
CONFIG_MANIFEST="$REPO_ROOT/manifests/config-paths.txt"

check_manifest() {
  local label="$1"
  local base="$2"
  local manifest="$3"
  local missing=0
  local found=0

  echo "$label"
  echo "$(printf '%*s' ${#label} '' | tr ' ' '-')"

  while IFS= read -r rel || [[ -n "$rel" ]]; do
    [[ -z "$rel" || "$rel" =~ ^[[:space:]]*# ]] && continue

    if [[ -e "$base/$rel" || -L "$base/$rel" ]]; then
      echo "[ok]      $base/$rel"
      ((found+=1))
    else
      echo "[missing] $base/$rel"
      ((missing+=1))
    fi
  done < "$manifest"

  echo "Summary: found=$found missing=$missing"
  echo ""
}

check_manifest "Home Manifest" "$HOME" "$HOME_MANIFEST"
check_manifest "Config Manifest" "$HOME/.config" "$CONFIG_MANIFEST"