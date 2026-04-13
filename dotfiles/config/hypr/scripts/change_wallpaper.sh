#!/bin/bash

DIR="$HOME/Pictures/Wallpapers"

# 0. Fix spaces in filenames (hyprctl breaks if images have spaces in their names)
for f in "$DIR"/*\ *; do
    if [ -f "$f" ]; then
        mv "$f" "${f// /_}"
    fi
done

# 1. Safely find a random image
RANDOM_PIC=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | shuf -n 1)

# Check if we actually found a picture
if [ -z "$RANDOM_PIC" ]; then
    notify-send "Wallpaper Error" "No images found in $DIR"
    exit 1
fi

# 2. Tell hyprpaper to load the new image and set it
hyprctl hyprpaper preload "$RANDOM_PIC"
hyprctl hyprpaper wallpaper ",$RANDOM_PIC"

# 3. Save it to hyprpaper.conf so it persists when you reboot your PC
echo "preload = $RANDOM_PIC" > ~/.config/hypr/hyprpaper.conf
echo "wallpaper = ,$RANDOM_PIC" >> ~/.config/hypr/hyprpaper.conf
echo "splash = false" >> ~/.config/hypr/hyprpaper.conf

# 4. Unload old images to free up RAM safely
hyprctl hyprpaper unload unused
