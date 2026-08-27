# My dotfiles

This repository stores the live configuration used by Hyprland and Waybar.

## Layout

- `dotfiles/config/hypr/` contains the native Hyprland `.conf` setup, wallpaper scripts, and Hyprpaper configuration.
- `dotfiles/config/waybar/` contains the Waybar configuration and styling.
- The `.lua` files under Hyprland are an alternate HyprMod setup. The active configuration uses `hyprland.conf` and the `.conf` files.

## Install or restore

From the repository root:

```fish
cp -a dotfiles/config/hypr/. "$HOME/.config/hypr/"
cp -a dotfiles/config/waybar/. "$HOME/.config/waybar/"
hyprctl reload
pkill -x waybar 2>/dev/null
waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/style.css" >/tmp/waybar.log 2>&1 &
```

Log out and back into Hyprland to test all `exec-once` startup entries. A Hyprland reload does not rerun `exec-once` commands.

## Wallpaper and colors

Place supported images in `~/Pictures/Wallpapers`:

```text
jpg, jpeg, png, gif, webp
```

Change the wallpaper and regenerate all themes:

```fish
~/.config/hypr/scripts/change_wallpaper.sh
```

The script selects a random wallpaper, applies it to active monitors, saves the path to `hyprpaper.conf`, and refreshes Hyprland and Waybar. `update-theme.sh` samples the wallpaper for the background. It automatically uses light text on dark backgrounds and dark text on light backgrounds.

Regenerate from a specific image:

```fish
~/.config/hypr/scripts/update-theme.sh "$HOME/Pictures/Wallpapers/example.jpg" --reload
```

## Keep the repository current

After changing the live configuration, synchronize it back to this repository:

```fish
rsync -a --delete --exclude='__pycache__/' "$HOME/.config/hypr/" /mnt/Projects/GIT/my_dotfiles/dotfiles/config/hypr/
rsync -a --delete --exclude='__pycache__/' "$HOME/.config/waybar/" /mnt/Projects/GIT/my_dotfiles/dotfiles/config/waybar/
git -C /mnt/Projects/GIT/my_dotfiles status
```

Review generated files before committing, especially `generated-theme.conf`, `hyprpaper.conf`, and `theme.css`, because they change when the wallpaper changes.

## Verify

```fish
bash -n "$HOME/.config/hypr/scripts/change_wallpaper.sh" "$HOME/.config/hypr/scripts/update-theme.sh"
timeout 3s waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/style.css"
```
