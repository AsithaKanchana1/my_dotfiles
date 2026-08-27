#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:-}"
RELOAD="${2:-}"
CONFIG_DIR="$HOME/.config"
HYPR_THEME="$CONFIG_DIR/hypr/config/generated-theme.conf"
WAYBAR_THEME="$CONFIG_DIR/waybar/theme.css"
KITTY_THEME="$CONFIG_DIR/kitty/theme.conf"

if [ -z "$IMAGE" ]; then
    IMAGE=$(sed -n 's/^wallpaper = ,//p' "$CONFIG_DIR/hypr/hyprpaper.conf" | tail -n 1)
fi

if [ ! -f "$IMAGE" ]; then
    exit 0
fi

mapfile -t COLORS < <(
    magick "$IMAGE" -resize 160x160 -colors 8 -unique-colors txt:- 2>/dev/null |
        awk -F'#' 'NR > 1 && NF > 1 { print substr($2, 1, 6) }' |
        head -n 3
)

BACKGROUND="${COLORS[0]:-1e1e2e}"
ACCENT="${COLORS[1]:-89b4fa}"
HIGHLIGHT="${COLORS[2]:-cba6f7}"

hex_to_rgb() {
    local value="${1#\#}"
    printf '%d, %d, %d' "0x${value:0:2}" "0x${value:2:2}" "0x${value:4:2}"
}

read -r RED GREEN BLUE <<< "$(hex_to_rgb "$BACKGROUND" | tr ',' ' ')"
LUMINANCE=$((RED * 299 + GREEN * 587 + BLUE * 114))
if [ "$LUMINANCE" -gt 150000 ]; then
    FOREGROUND="#111318"
else
    FOREGROUND="#f4f7fb"
fi

printf '$color2 = rgb(%s)\n$color4 = rgb(%s)\n$background = rgb(%s)\n' \
    "$ACCENT" "$HIGHLIGHT" "$BACKGROUND" > "$HYPR_THEME"

cat > "$WAYBAR_THEME" <<EOF
@define-color bar_background #${BACKGROUND};
@define-color module_background #${BACKGROUND};
@define-color foreground $FOREGROUND;
@define-color accent #$ACCENT;
@define-color highlight #$HIGHLIGHT;
EOF

cat > "$KITTY_THEME" <<EOF
background #$BACKGROUND
foreground $FOREGROUND
cursor #$HIGHLIGHT
selection_background #$ACCENT
selection_foreground $FOREGROUND
EOF

if [ "$RELOAD" = "--reload" ]; then
    hyprctl reload
    pkill -SIGUSR2 waybar 2>/dev/null || true
fi