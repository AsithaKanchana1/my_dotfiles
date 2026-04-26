#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CATALOG_INDEX="$REPO_ROOT/packages/catalog/index.tsv"

declare -a CATEGORY_KEYS=()
declare -a CATEGORY_LABELS=()
declare -a CATEGORY_DESCRIPTIONS=()
declare -a CATEGORY_FILES=()

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

load_catalog() {
  local key label description file

  while IFS=$'\t' read -r key label description file; do
    [[ -z "$key" ]] && continue
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    CATEGORY_KEYS+=("$key")
    CATEGORY_LABELS+=("$label")
    CATEGORY_DESCRIPTIONS+=("$description")
    CATEGORY_FILES+=("$file")
  done < "$CATALOG_INDEX"
}

count_selected() {
  local -n selected_ref=$1
  local count=0
  local value

  for value in "${selected_ref[@]}"; do
    if [[ "$value" -eq 1 ]]; then
      count=$((count + 1))
    fi
  done

  printf '%s' "$count"
}

install_category_file() {
  local file="$1"
  local label="$2"
  local package_path="$REPO_ROOT/$file"

  read_package_file "$package_path"
  if ((${#PKGS[@]} == 0)); then
    echo "Skipping empty category: $label"
    return
  fi

  echo "Installing $label..."
  yay -S --noconfirm --needed "${PKGS[@]}"
}

show_details() {
  local index="$1"
  local package_path="$REPO_ROOT/${CATEGORY_FILES[$index]}"
  local pkg

  printf '\033[H\033[2J'
  echo "Software Catalog - Details"
  echo "--------------------------"
  printf "Category: %s\n" "${CATEGORY_LABELS[$index]}"
  printf "Key: %s\n\n" "${CATEGORY_KEYS[$index]}"
  printf "%s\n\n" "${CATEGORY_DESCRIPTIONS[$index]}"
  echo "Packages:"

  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue
    printf '  - %s\n' "$pkg"
  done < <(grep -vE '^\s*$|^\s*#' "$package_path")

  echo
  echo "Controls: q=close details"
}

show_menu() {
  local selected=0
  local total="${#CATEGORY_KEYS[@]}"
  local key=""
  local key2=""
  local key3=""
  local i
  local -a chosen=()

  for ((i = 0; i < total; i++)); do
    chosen+=(0)
  done

  for ((i = 0; i < total; i++)); do
    if [[ "${CATEGORY_KEYS[$i]}" == core ]]; then
      chosen[$i]=1
    fi
  done

  while true; do
    printf '\033[H\033[2J'
    echo "Software Catalog"
    echo "----------------"
    echo "Use ↑/↓ (or j/k), Space to toggle, Enter to install, d for details, a for all, n for none, q to quit."
    echo

    for ((i = 0; i < total; i++)); do
      if [[ "$i" -eq "$selected" ]]; then
        if [[ "${chosen[$i]}" -eq 1 ]]; then
          printf " > [x] %-24s %s (%s)\n" "${CATEGORY_KEYS[$i]}" "${CATEGORY_LABELS[$i]}" "${CATEGORY_DESCRIPTIONS[$i]}"
        else
          printf " > [ ] %-24s %s (%s)\n" "${CATEGORY_KEYS[$i]}" "${CATEGORY_LABELS[$i]}" "${CATEGORY_DESCRIPTIONS[$i]}"
        fi
      else
        if [[ "${chosen[$i]}" -eq 1 ]]; then
          printf "   [x] %-24s %s\n" "${CATEGORY_KEYS[$i]}" "${CATEGORY_LABELS[$i]}"
        else
          printf "   [ ] %-24s %s\n" "${CATEGORY_KEYS[$i]}" "${CATEGORY_LABELS[$i]}"
        fi
      fi
    done

    echo
    printf "Selected categories: %s/%d\n" "$(count_selected chosen)" "$total"
    printf "Footer: Enter=install  Space=toggle  d=details  a=all  n=none  q=quit\n"

    key=""
    key2=""
    key3=""
    IFS= read -rsn1 key || true
    if [[ "$key" == $'\x1b' ]]; then
      IFS= read -rsn1 -t 0.05 key2 || key2=""
      IFS= read -rsn1 -t 0.05 key3 || key3=""
      key+="$key2$key3"
    fi

    case "$key" in
      $'\x1b[A'|k|K)
        selected=$(((selected - 1 + total) % total))
        ;;
      $'\x1b[B'|j|J)
        selected=$(((selected + 1) % total))
        ;;
      ' ')
        chosen[$selected]=$((1 - chosen[$selected]))
        ;;
      a|A)
        for ((i = 0; i < total; i++)); do
          chosen[$i]=1
        done
        ;;
      n|N)
        for ((i = 0; i < total; i++)); do
          chosen[$i]=0
        done
        ;;
      d|D)
        while true; do
          show_details "$selected"
          IFS= read -rsn1 key || true
          if [[ "$key" == q || "$key" == Q ]]; then
            break
          fi
        done
        ;;
      q|Q)
        echo
        echo "Bye."
        break
        ;;
      $'\n'|$'\r')
        if [[ "$(count_selected chosen)" -eq 0 ]]; then
          printf '\nSelect at least one category with Space or press a to select all.\n'
          IFS= read -rsn1 key || true
          continue
        fi

        echo
        echo "Installing selected categories..."
        for ((i = 0; i < total; i++)); do
          if [[ "${chosen[$i]}" -eq 1 ]]; then
            install_category_file "${CATEGORY_FILES[$i]}" "${CATEGORY_LABELS[$i]}"
          fi
        done
        if command -v rustup >/dev/null 2>&1; then
          rustup default stable
        fi
        echo "Package installation complete."
        break
        ;;
      *)
        ;;
    esac
  done
}

run_selected_categories() {
  local categories_csv="$1"
  local key
  local i
  IFS=',' read -r -a requested <<< "$categories_csv"

  for key in "${requested[@]}"; do
    for ((i = 0; i < ${#CATEGORY_KEYS[@]}; i++)); do
      if [[ "${CATEGORY_KEYS[$i]}" == "$key" ]]; then
        install_category_file "${CATEGORY_FILES[$i]}" "${CATEGORY_LABELS[$i]}"
        break
      fi
    done
  done

  if command -v rustup >/dev/null 2>&1; then
    rustup default stable
  fi
  echo "Package installation complete."
}

main() {
  local categories_csv=""
  local install_all=0
  local list_only=0
  local force_interactive=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)
        install_all=1
        shift
        ;;
      --categories)
        categories_csv+="${2:-},"
        shift 2
        ;;
      --list)
        list_only=1
        shift
        ;;
      --interactive)
        force_interactive=1
        shift
        ;;
      -h|--help)
        cat <<'EOF'
Usage:
  install-software.sh
  install-software.sh --interactive
  install-software.sh --categories core,desktop
  install-software.sh --all
  install-software.sh --list
EOF
        return 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        return 1
        ;;
    esac
  done

  load_catalog

  if [[ "$list_only" -eq 1 ]]; then
    printf '%-24s %s\n' "CATEGORY" "LABEL"
    list_catalog
    return 0
  fi

  install_yay_if_missing

  if [[ "$install_all" -eq 1 ]]; then
    local i
    for ((i = 0; i < ${#CATEGORY_KEYS[@]}; i++)); do
      install_category_file "${CATEGORY_FILES[$i]}" "${CATEGORY_LABELS[$i]}"
    done
    if command -v rustup >/dev/null 2>&1; then
      rustup default stable
    fi
    echo "Package installation complete."
    return 0
  fi

  if [[ -n "$categories_csv" ]]; then
    run_selected_categories "${categories_csv%,}"
    return 0
  fi

  if [[ "$force_interactive" -eq 1 || $# -eq 0 ]]; then
    if [[ ! -t 0 ]]; then
      echo "Interactive software selection requires a TTY. Use --categories or --all." >&2
      return 1
    fi
    show_menu
    return 0
  fi
}

main "$@"