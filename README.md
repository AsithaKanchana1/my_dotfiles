# My dotfiles - CachyOS + Hyprland

Personal configuration backup for CachyOS Linux with Hyprland. The active branch is
`conv-lua`, which keeps the current `.conf`-based Hyprland setup together with the
alternate Lua (`hyprland.lua`) configuration.

All application configs mirror `~/.config`; shell dotfiles mirror `$HOME`.

## Repository layout

```text
.
├── dotfiles/
│   ├── config/        # copy of ~/.config (curated)
│   └── home/          # copy of $HOME dotfiles
├── packages/          # package and user-service inventory
├── scripts/
│   ├── backup.sh      # live system -> this repository
│   └── restore.sh     # this repository -> live system
└── README.md
```

## Catalog

### Desktop and window management

| Path | Application | Contents and notes |
| --- | --- | --- |
| `dotfiles/config/hypr/` | Hyprland | `hyprland.conf`, modular `config/*.conf`, HyprMod profile, wallpaper scripts, `hyprpaper.conf` |
| `dotfiles/config/hypr/config/` | Hyprland | Theme, appearance, input, bindings, autostart, monitor/program, environment rules, generated colors |
| `dotfiles/config/hypr/hyprmod/` | HyprMod | Active profile ID and managed `hyprland-gui.conf` snapshot |
| `dotfiles/config/hypr/backup_lua/` | Hyprland (Lua) | Full alternate Lua configuration kept for reference/migration |
| `dotfiles/config/hypr/hyprland.lua` | Hyprland (Lua) | Alternate Lua entry point, not loaded by the active `hyprland.conf` |
| `dotfiles/config/hypr/scripts/` | Hyprland | `change_wallpaper.sh` and `update-theme.sh` |
| `dotfiles/config/waybar/` | Waybar | `config.jsonc`, `style.css`, `theme.css`, media player and update-check scripts |
| `dotfiles/config/rofi/` | Rofi | Launcher, power menu, Nord themes |
| `dotfiles/config/wofi/` | Wofi | Launcher config and style |
| `dotfiles/config/noctalia/` | Noctalia | Shell/theme configuration |
| `dotfiles/config/kitty/` | Kitty | Terminal config and theme |
| `dotfiles/config/alacritty/` | Alacritty | Terminal config and Noctalia theme |
| `dotfiles/config/satty/` | Satty | Screenshot annotation config |
| `dotfiles/config/xsettingsd/` | Xsettingsd | XDG appearance settings for XWayland apps |
| `dotfiles/config/gtk-3.0/` | GTK 3 | File manager bookmarks |
| `dotfiles/config/gtk-4.0/` | GTK 4 | XDG portal server preferences |
| `dotfiles/config/qt5ct/`, `dotfiles/config/qt6ct/` | Qt | Qt appearance and Noctalia color schemes |
| `dotfiles/config/menus/` | XDG menus | User application menu definitions |

### Applications and tools

| Path | Application | Contents and notes |
| --- | --- | --- |
| `dotfiles/config/fish/` | Fish shell | `config.fish`; API token is redacted, `fish_variables` is excluded |
| `dotfiles/config/nvim/` | Neovim | LazyVim/titus-kickstart config, plugin locks, custom plugin specs |
| `dotfiles/config/micro/` | Micro editor | `settings.json` and Catppuccin color schemes (upstream syntax files excluded) |
| `dotfiles/config/yazi/` | Yazi | File manager settings |
| `dotfiles/config/btop/` | btop | Resource monitor config and Noctalia theme |
| `dotfiles/config/fastfetch/` | Fastfetch | System information layout |
| `dotfiles/config/htop/` | htop | Monitor settings |
| `dotfiles/config/crossnote/` | Crossnote | Markdown preview configuration |
| `dotfiles/config/vlc/` | VLC | Playback and Qt interface settings |
| `dotfiles/config/Code/User/` | VS Code | Settings, keybindings, MCP and chat model config only (workspace data excluded) |
| `dotfiles/config/opencode/` | OpenCode | `opencode.jsonc`, plugin manifest and lockfile (node_modules excluded) |
| `dotfiles/config/gh/` | GitHub CLI | `config.yml` only; `hosts.yml` credentials are never committed |
| `dotfiles/config/cachyos/` | CachyOS | Package Installer config and package list |
| `dotfiles/config/topgrade.toml` | Topgrade | Upgrade tool configuration |
| `dotfiles/config/glib-2.0/` | GLib | Desktop settings keyfile |

### KDE, user defaults, and home files

| Path | Contents |
| --- | --- |
| `dotfiles/config/kdeglobals`, `dolphinrc`, `baloofileinformationrc` | KDE appearance and Dolphin/Baloo settings |
| `dotfiles/config/mimeapps.list`, `cpak-mimeapps.list` | Default application associations |
| `dotfiles/config/user-dirs.dirs`, `user-dirs.locale` | XDG user directory names and locale |
| `dotfiles/config/pavucontrol.ini`, `QtProject.conf`, `cachyos-hello.json` | Small per-user application settings |
| `dotfiles/home/.bashrc`, `.bash_profile`, `.bash_logout` | Bash startup files |
| `dotfiles/home/.zshrc` | Zsh configuration |
| `dotfiles/home/.gitconfig`, `.gitconfig.cachyos` | Git identity and credential helper |
| `dotfiles/home/.wakatime.cfg` | WakaTime CLI settings |

### Inventory

| Path | Contents |
| --- | --- |
| `packages/pacman-explicit.txt` | Explicitly installed pacman packages |
| `packages/pacman-aur.txt` | Foreign/AUR packages |
| `packages/systemd-user-units.txt` | Enabled systemd user units |

## Intentionally not backed up

Browser profiles, Thunderbird mail, VS Code/Brave/Chrome data, Electron caches,
`node_modules`, `dconf` databases, PulseAudio cookies, GitHub CLI credentials,
`fish_variables`, Python caches, `*.bak` copies, and wallpaper images. These are
large, machine-specific, generated, or contain credentials.

HyprMod may regenerate `hyprland-gui.conf`; wallpaper changes rewrite
`config/generated-theme.conf`, `hyprpaper.conf`, `waybar/theme.css`, and
`kitty/theme.conf`, so review those diffs before committing.

## Prerequisites

A CachyOS/Arch system with Hyprland, Git, and rsync:

```fish
sudo pacman -S --needed git rsync
```

Install the recorded packages if setting up a new machine:

```fish
sudo pacman -S --needed - < packages/pacman-explicit.txt
yay -S --needed - < packages/pacman-aur.txt
```

Some AUR helpers require these to run one at a time; the list above is small.

## Restore

Clone the branch and restore everything:

```fish
git clone -b conv-lua https://github.com/AsithaKanchana1/my_dotfiles.git
cd my_dotfiles
./scripts/restore.sh
```

The restore script copies existing files to `~/config-backup-<timestamp>` before
overwriting, then copies the repository contents into `~/.config` and `$HOME`
without deleting unrelated files.

Some configs contain absolute paths such as `/home/asithakanchana` (Hyprland
sources, VS Code tool paths, Fish `PNPM_HOME`). Update those if restoring under a
different username.

Restore a single application manually:

```fish
rsync -a dotfiles/config/hypr/ ~/.config/hypr/
rsync -a dotfiles/config/waybar/ ~/.config/waybar/
```

After restoring:

1. Set the real `ANTHROPIC_AUTH_TOKEN` in `~/.config/fish/config.fish` (the
   committed value is redacted).
2. Reload Hyprland and restart Waybar:

   ```fish
   hyprctl reload
   pkill -x waybar 2>/dev/null
   waybar >/tmp/waybar.log 2>&1 &
   ```

3. Log out and back in to Hyprland so `exec-once` entries run again.
4. Start Neovim once to install plugins from `lazy-lock.json`.
5. Optionally set Fish as the login shell with `chsh -s /usr/bin/fish`.

## Backup this machine

Run the backup script from the repository root:

```fish
./scripts/backup.sh
git status
git add -A
git commit -m "backup: update configurations"
git push origin conv-lua
```

The script refreshes every catalogued path, regenerates the package inventory,
sanitizes the Fish token, and deletes stale files inside synced directories.

## Hyprland wallpaper and theme

Place wallpapers in `~/Pictures/Wallpapers` (jpg, jpeg, png, gif, webp):

```fish
~/.config/hypr/scripts/change_wallpaper.sh
```

The script selects a random wallpaper, applies it to active monitors, saves the
path to `hyprpaper.conf`, and refreshes Hyprland and Waybar. To regenerate from a
specific image:

```fish
~/.config/hypr/scripts/update-theme.sh "$HOME/Pictures/Wallpapers/example.jpg" --reload
```

## Verify

```fish
bash -n scripts/backup.sh scripts/restore.sh
bash -n dotfiles/config/hypr/scripts/change_wallpaper.sh
bash -n dotfiles/config/hypr/scripts/update-theme.sh
timeout 3s waybar -c dotfiles/config/waybar/config.jsonc -s dotfiles/config/waybar/style.css
```
