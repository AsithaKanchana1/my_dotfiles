#!/usr/bin/env bash

set -euo pipefail

DIR="$HOME/Pictures/Wallpapers"

if [ ! -d "$DIR" ]; then
  notify-send "Wallpaper Error" "Directory not found: $DIR"
  exit 0
fi

# 0. Ensure hyprpaper is running silently in the background
if ! pgrep -x "hyprpaper" >/dev/null; then
  hyprpaper >/dev/null 2>&1 &
  sleep 1
fi

# 1. Fix spaces in filenames
for f in "$DIR"/*\ *; do
  if [ -f "$f" ]; then
    mv "$f" "${f// /_}"
  fi
done

# 2. Safely find a random image
RANDOM_PIC=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | shuf -n 1)

if [ -z "$RANDOM_PIC" ]; then
  notify-send "Wallpaper Error" "No images found in $DIR"
  exit 1
fi

# 3. Apply it to all active monitors dynamically!
# (No preload or unload needed anymore in Hyprpaper v0.8+)
for monitor in $(hyprctl monitors | awk '/^Monitor/ {print $2}'); do
  hyprctl hyprpaper wallpaper "$monitor,$RANDOM_PIC"
done

# 4. Save it to hyprpaper.conf so it persists when you reboot
# (We removed the old preload requirement here too)
echo "wallpaper = ,$RANDOM_PIC" >~/.config/hypr/hyprpaper.conf
echo "splash = false" >>~/.config/hypr/hyprpaper.conf

# 5. Generate the shared theme and refresh Hyprland and Waybar
"$HOME/.config/hypr/scripts/update-theme.sh" "$RANDOM_PIC" --reload
