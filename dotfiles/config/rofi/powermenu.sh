#!/usr/bin/env bash
set -e
set -u

all=(shutdown reboot suspend hibernate logout lockscreen)
show=("${all[@]}")

declare -A texts
texts[lockscreen]="lock screen"
texts[switchuser]="switch user"
texts[logout]="log out"
texts[suspend]="suspend"
texts[hibernate]="hibernate"
texts[reboot]="reboot"
texts[shutdown]="shut down"

declare -A icons
declare -A material_icons
declare -A nerd_font_icons

material_icons[lockscreen]="lock"
material_icons[switchuser]="switch_account"
material_icons[logout]="logout"
material_icons[suspend]="bedtime"
material_icons[hibernate]="hotel"
material_icons[reboot]="restart_alt"
material_icons[shutdown]="power_settings_new"
material_icons[cancel]="close"

nerd_font_icons[lockscreen]=$'\Uf033e'
nerd_font_icons[switchuser]=$'\Uf0019'
nerd_font_icons[logout]=$'\Uf0343'
nerd_font_icons[suspend]=$'\Uf04b2'
nerd_font_icons[hibernate]=$'\Uf02ca'
nerd_font_icons[reboot]=$'\Uf0709'
nerd_font_icons[shutdown]=$'\Uf0425'
nerd_font_icons[cancel]=$'\Uf0156'

declare -A actions
actions[lockscreen]="loginctl lock-session ${XDG_SESSION_ID-}"
actions[logout]="loginctl terminate-session ${XDG_SESSION_ID-}"
actions[suspend]="systemctl suspend"
actions[hibernate]="systemctl hibernate"
actions[reboot]="systemctl reboot"
actions[shutdown]="systemctl poweroff"

confirmations=(reboot shutdown logout)
dryrun=false
showsymbols=true
showtext=true

font_exists() {
  local candidate="$1"
  if fc-match "$candidate" 2>/dev/null | command grep -Fqi "$candidate"; then
    return 0
  fi
  return 1
}

detect_symbols_font() {
  local candidate
  for candidate in \
    "Symbols Nerd Font Mono" \
    "Symbols Nerd Font" \
    "JetBrainsMono Nerd Font" \
    "MesloLGS NF" \
    "Material Icons"; do
    if font_exists "$candidate"; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  return 1
}

use_material_icons() {
  case "$1" in
  "Material Icons" | "Material Icons Outlined" | "Material Icons Round" | "Material Icons Sharp" | "Material Icons Two Tone")
    return 0
    ;;
  esac
  return 1
}

set_icons() {
  local entry
  if use_material_icons "$1"; then
    for entry in "${!material_icons[@]}"; do
      icons[$entry]="${material_icons[$entry]}"
    done
    return 0
  fi
  for entry in "${!nerd_font_icons[@]}"; do
    icons[$entry]="${nerd_font_icons[$entry]}"
  done
}

symbols_font=""
if detected_symbols_font=$(detect_symbols_font); then
  symbols_font="$detected_symbols_font"
fi
set_icons "$symbols_font"

check_valid() {
  local option="$1"
  shift 1
  for entry in "${@}"; do
    if [ -z "${actions[$entry]+x}" ]; then
      echo "Invalid choice in $option: $entry" >&2
      exit 1
    fi
  done
}

parsed=$(getopt --options=h --longoptions=help,dry-run,confirm:,choices:,choose:,symbols,no-symbols,text,no-text,symbols-font: --name "$0" -- "$@") || exit 1
eval set -- "$parsed"
unset parsed

while true; do
  case "$1" in
  "-h" | "--help")
    echo "Usage: powermenu.sh [--choices CHOICES] [--confirm CHOICES] [--choose CHOICE] [--dry-run]"
    exit 0
    ;;
  "--dry-run")
    dryrun=true
    shift 1
    ;;
  "--confirm")
    IFS='/' read -ra confirmations <<<"$2"
    check_valid "$1" "${confirmations[@]}"
    shift 2
    ;;
  "--choices")
    IFS='/' read -ra show <<<"$2"
    check_valid "$1" "${show[@]}"
    shift 2
    ;;
  "--choose")
    check_valid "$1" "$2"
    selectionID="$2"
    shift 2
    ;;
  "--symbols")
    showsymbols=true
    shift 1
    ;;
  "--no-symbols")
    showsymbols=false
    shift 1
    ;;
  "--text")
    showtext=true
    shift 1
    ;;
  "--no-text")
    showtext=false
    shift 1
    ;;
  "--symbols-font")
    symbols_font="$2"
    set_icons "$symbols_font"
    shift 2
    ;;
  "--")
    shift
    break
    ;;
  *)
    echo "Internal error" >&2
    exit 1
    ;;
  esac
done

if [ "$showsymbols" = "false" ] && [ "$showtext" = "false" ]; then
  echo "Invalid options: cannot have --no-symbols and --no-text enabled at the same time." >&2
  exit 1
fi

write_message() {
  local icon text
  if [ -n "$symbols_font" ]; then
    icon="<span font=\"${symbols_font}\" font_size=\"medium\">$1</span>"
  else
    icon="<span font_size=\"medium\">$1</span>"
  fi
  text="<span font_size=\"medium\">$2</span>"
  if [ "$showsymbols" = "true" ]; then
    if [ "$showtext" = "true" ]; then
      printf '\u200e%s \u2068%s\u2069' "$icon" "$text"
    else
      printf '\u200e%s' "$icon"
    fi
  else
    printf '%s' "$text"
  fi
}

print_selection() {
  printf '%b' "$1"
}

declare -A messages
declare -A confirmationMessages

for entry in "${all[@]}"; do
  messages[$entry]=$(write_message "${icons[$entry]}" "${texts[$entry]^}")
done

for entry in "${all[@]}"; do
  confirmationMessages[$entry]=$(write_message "${icons[$entry]}\u200b" "Yes, ${texts[$entry]}")
done
confirmationMessages[cancel]=$(write_message "${icons[cancel]}" "No, cancel")

if [ $# -gt 0 ]; then
  selection="$*"
else
  if [ -n "${selectionID+x}" ]; then
    selection="${messages[$selectionID]}"
  fi
fi

if [ -z "${ROFI_RETV+x}" ]; then
  exec rofi -show powermenu -modi "powermenu:$0" \
    -config "$HOME/.config/rofi/config.rasi" \
    -theme "$HOME/.config/rofi/themes/powermenu.rasi"
fi

echo -e "\0no-custom\x1ftrue"
echo -e "\0markup-rows\x1ftrue"

if [ -z "${selection+x}" ]; then
  echo -e "\0prompt\x1fPower menu"
  for entry in "${show[@]}"; do
    echo -e "${messages[$entry]}"
  done
else
  for entry in "${show[@]}"; do
    if [ "$selection" = "$(print_selection "${messages[$entry]}")" ]; then
      for confirmation in "${confirmations[@]}"; do
        if [ "$entry" = "$confirmation" ]; then
          echo -e "\0prompt\x1fAre you sure"
          echo -e "${confirmationMessages[$entry]}"
          echo -e "${confirmationMessages[cancel]}"
          exit 0
        fi
      done
      selection=$(print_selection "${confirmationMessages[$entry]}")
    fi
    if [ "$selection" = "$(print_selection "${confirmationMessages[$entry]}")" ]; then
      if [ "$dryrun" = true ]; then
        echo "Selected: $entry" >&2
      else
        ${actions[$entry]}
      fi
      exit 0
    fi
    if [ "$selection" = "$(print_selection "${confirmationMessages[cancel]}")" ]; then
      exit 0
    fi
  done
  echo "Invalid selection: $selection" >&2
  exit 1
fi
