#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CATALOG_INDEX="$REPO_ROOT/packages/catalog/index.tsv"

declare -a CATEGORY_KEYS=()
declare -a CATEGORY_LABELS=()
declare -a CATEGORY_DESCRIPTIONS=()
declare -a CATEGORY_FILES=()

# Maps: CATEGORY_KEY -> CSV of packages
declare -A CATEGORY_PACKAGES=()
# Maps: PACKAGE_NAME -> 1 (selected) or 0 (unselected)
declare -A PKG_SELECTED=()

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
  local key label description file package_path pkg
  local -a pkgs_array

  while IFS=$'\t' read -r key label description file; do
    [[ -z "$key" ]] && continue
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    CATEGORY_KEYS+=("$key")
    CATEGORY_LABELS+=("$label")
    CATEGORY_DESCRIPTIONS+=("$description")
    CATEGORY_FILES+=("$file")

    package_path="$REPO_ROOT/$file"
    pkgs_array=()
    if [[ -f "$package_path" ]]; then
      while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue
        pkgs_array+=("$pkg")
        # Default all to 0
        PKG_SELECTED["$pkg"]=0
      done < <(grep -vE '^\s*$|^\s*#' "$package_path")
    fi
    CATEGORY_PACKAGES["$key"]="$(IFS=,; echo "${pkgs_array[*]}")"
  done < "$CATALOG_INDEX"
}

set_category_selected() {
  local key="$1"
  local val="$2"
  local pkg
  local pkgs="${CATEGORY_PACKAGES["$key"]:-}"
  if [[ -n "$pkgs" ]]; then
    IFS=',' read -r -a pkgs_array <<< "$pkgs"
    for pkg in "${pkgs_array[@]}"; do
      PKG_SELECTED["$pkg"]="$val"
    done
  fi
}

get_category_selected_count() {
  local key="$1"
  local count=0
  local pkg
  local pkgs="${CATEGORY_PACKAGES["$key"]:-}"
  if [[ -n "$pkgs" ]]; then
    IFS=',' read -r -a pkgs_array <<< "$pkgs"
    for pkg in "${pkgs_array[@]}"; do
      if [[ "${PKG_SELECTED["$pkg"]}" -eq 1 ]]; then
        count=$((count + 1))
      fi
    done
  fi
  echo "$count"
}

get_category_total_count() {
  local key="$1"
  local pkgs="${CATEGORY_PACKAGES["$key"]:-}"
  if [[ -z "$pkgs" ]]; then
    echo "0"
  else
    IFS=',' read -r -a pkgs_array <<< "$pkgs"
    echo "${#pkgs_array[@]}"
  fi
}

get_total_selected_count() {
  local count=0
  local pkg
  for pkg in "${!PKG_SELECTED[@]}"; do
    if [[ "${PKG_SELECTED["$pkg"]}" -eq 1 ]]; then
      count=$((count + 1))
    fi
  done
  echo "$count"
}

list_catalog() {
  local i key
  for ((i = 0; i < ${#CATEGORY_KEYS[@]}; i++)); do
    key="${CATEGORY_KEYS[$i]}"
    printf '%-24s %s\n' "$key" "${CATEGORY_LABELS[$i]}"
  done
}

show_submenu() {
  local cat_index="$1"
  local key="${CATEGORY_KEYS[$cat_index]}"
  local label="${CATEGORY_LABELS[$cat_index]}"
  local pkgs="${CATEGORY_PACKAGES["$key"]:-}"
  local -a pkgs_array=()
  
  if [[ -n "$pkgs" ]]; then
    IFS=',' read -r -a pkgs_array <<< "$pkgs"
  fi

  local total="${#pkgs_array[@]}"
  if (( total == 0 )); then
    echo "No packages in this category."
    sleep 1
    return
  fi

  local selected=0
  local input_key=""
  local key2=""
  local key3=""
  local i pkg

  while true; do
    printf '\033[H\033[2J'
    echo "Software Catalog > $label"
    echo "--------------------------------------------------------"
    echo "Use ↑/↓ (or j/k), Space to toggle, a=all, n=none, q=back(save), x=back(clear)."
    echo

    for ((i = 0; i < total; i++)); do
      pkg="${pkgs_array[$i]}"
      if [[ "$i" -eq "$selected" ]]; then
        if [[ "${PKG_SELECTED["$pkg"]}" -eq 1 ]]; then
          printf " > [x] %s\n" "$pkg"
        else
          printf " > [ ] %s\n" "$pkg"
        fi
      else
        if [[ "${PKG_SELECTED["$pkg"]}" -eq 1 ]]; then
          printf "   [x] %s\n" "$pkg"
        else
          printf "   [ ] %s\n" "$pkg"
        fi
      fi
    done

    echo
    printf "Category Selection: %d/%d\n" "$(get_category_selected_count "$key")" "$total"
    printf "Footer: Space=toggle  a=all  n=none  q=back(save)  x=back(clear)\n"

    input_key=""
    key2=""
    key3=""
    IFS= read -rsn1 input_key || true
    if [[ "$input_key" == $'\x1b' ]]; then
      IFS= read -rsn1 -t 0.05 key2 || key2=""
      IFS= read -rsn1 -t 0.05 key3 || key3=""
      input_key+="$key2$key3"
    fi

    case "$input_key" in
      $'\x1b[A'|k|K) selected=$(((selected - 1 + total) % total)) ;;
      $'\x1b[B'|j|J) selected=$(((selected + 1) % total)) ;;
      ' ')
        pkg="${pkgs_array[$selected]}"
        PKG_SELECTED["$pkg"]=$((1 - PKG_SELECTED["$pkg"]))
        ;;
      a|A)
        for pkg in "${pkgs_array[@]}"; do
          PKG_SELECTED["$pkg"]=1
        done
        ;;
      n|N|c|C)
        for pkg in "${pkgs_array[@]}"; do
          PKG_SELECTED["$pkg"]=0
        done
        ;;
      q|Q)
        return
        ;;
      x|X)
        for pkg in "${pkgs_array[@]}"; do
          PKG_SELECTED["$pkg"]=0
        done
        return
        ;;
      *) ;;
    esac
  done
}

show_menu() {
  local selected=0
  local total="${#CATEGORY_KEYS[@]}"
  local input_key=""
  local key2=""
  local key3=""
  local i key cat_sel cat_tot

  # Preselect core
  set_category_selected "core" 1

  while true; do
    printf '\033[H\033[2J'
    echo "Software Catalog - Main Menu"
    echo "----------------------------"
    echo "Use ↑/↓, Enter to open category, Space to toggle all, i to install, c to clear, q to quit."
    echo

    for ((i = 0; i < total; i++)); do
      key="${CATEGORY_KEYS[$i]}"
      cat_sel="$(get_category_selected_count "$key")"
      cat_tot="$(get_category_total_count "$key")"
      
      if [[ "$i" -eq "$selected" ]]; then
        if [[ "$cat_sel" -gt 0 ]]; then
          printf " > [x] %-24s %s [%d/%d selected]\n" "$key" "${CATEGORY_LABELS[$i]}" "$cat_sel" "$cat_tot"
        else
          printf " > [ ] %-24s %s [%d/%d selected]\n" "$key" "${CATEGORY_LABELS[$i]}" "$cat_sel" "$cat_tot"
        fi
      else
        if [[ "$cat_sel" -gt 0 ]]; then
          printf "   [x] %-24s %s [%d/%d]\n" "$key" "${CATEGORY_LABELS[$i]}" "$cat_sel" "$cat_tot"
        else
          printf "   [ ] %-24s %s [%d/%d]\n" "$key" "${CATEGORY_LABELS[$i]}" "$cat_sel" "$cat_tot"
        fi
      fi
    done

    echo
    printf "Total Packages Selected: %d\n" "$(get_total_selected_count)"
    printf "Footer: Enter=open  Space=toggle_all  i=install  c=clear  q=quit\n"

    input_key=""
    key2=""
    key3=""
    IFS= read -rsn1 input_key || true
    if [[ "$input_key" == $'\x1b' ]]; then
      IFS= read -rsn1 -t 0.05 key2 || key2=""
      IFS= read -rsn1 -t 0.05 key3 || key3=""
      input_key+="$key2$key3"
    fi

    case "$input_key" in
      $'\x1b[A'|k|K) selected=$(((selected - 1 + total) % total)) ;;
      $'\x1b[B'|j|J) selected=$(((selected + 1) % total)) ;;
      ""|$'\n'|$'\r')
        show_submenu "$selected"
        ;;
      ' ')
        key="${CATEGORY_KEYS[$selected]}"
        cat_sel="$(get_category_selected_count "$key")"
        if [[ "$cat_sel" -gt 0 ]]; then
          set_category_selected "$key" 0
        else
          set_category_selected "$key" 1
        fi
        ;;
      c|C)
        for pkg in "${!PKG_SELECTED[@]}"; do
          PKG_SELECTED["$pkg"]=0
        done
        ;;
      q|Q)
        echo
        echo "Bye."
        break
        ;;
      i|I)
        if [[ "$(get_total_selected_count)" -eq 0 ]]; then
          printf '\nSelect at least one package before installing.\n'
          sleep 1
          continue
        fi

        echo
        echo "Installing selected packages..."
        local -a final_pkgs=()
        for pkg in "${!PKG_SELECTED[@]}"; do
          if [[ "${PKG_SELECTED["$pkg"]}" -eq 1 ]]; then
            final_pkgs+=("$pkg")
          fi
        done
        
        yay -S --noconfirm --needed "${final_pkgs[@]}"
        
        if command -v rustup >/dev/null 2>&1; then
          rustup default stable
        fi
        echo "Package installation complete."
        break
        ;;
      *) ;;
    esac
  done
}

run_selected_categories() {
  local categories_csv="$1"
  local key
  local i
  IFS=',' read -r -a requested <<< "$categories_csv"

  for key in "${requested[@]}"; do
    set_category_selected "$key" 1
  done

  local -a final_pkgs=()
  for pkg in "${!PKG_SELECTED[@]}"; do
    if [[ "${PKG_SELECTED["$pkg"]}" -eq 1 ]]; then
      final_pkgs+=("$pkg")
    fi
  done

  if ((${#final_pkgs[@]} == 0)); then
    echo "No packages found for categories: $categories_csv"
    return
  fi

  echo "Installing selected categories..."
  yay -S --noconfirm --needed "${final_pkgs[@]}"

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
      set_category_selected "${CATEGORY_KEYS[$i]}" 1
    done
    
    local -a final_pkgs=()
    for pkg in "${!PKG_SELECTED[@]}"; do
      if [[ "${PKG_SELECTED["$pkg"]}" -eq 1 ]]; then
        final_pkgs+=("$pkg")
      fi
    done
    
    yay -S --noconfirm --needed "${final_pkgs[@]}"
    
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