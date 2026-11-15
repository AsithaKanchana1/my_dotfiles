# Dotfiles Snapshot (`old-conf`)

Complete backup of the active `.conf`-based CachyOS + Hyprland desktop configuration prior to migrating to Lua configurations (`conv-lua`).

## Repository Structure

- `config/` -> Maps directly to `~/.config/`
- `home/` -> Maps directly to `~/`

## Configuration Catalog

| Component | Repo Path | System Target | Key Files |
| :--- | :--- | :--- | :--- |
| **btop** | \`config/btop/\` | \`~/.config/btop/\` | \`btop.conf,themes/noctalia.theme\` |
| **fastfetch** | \`config/fastfetch/\` | \`~/.config/fastfetch/\` | \`config.jsonc\` |
| **fish** | \`config/fish/\` | \`~/.config/fish/\` | \`config.fish,fish_variables\` |
| **gtk-3.0** | \`config/gtk-3.0/\` | \`~/.config/gtk-3.0/\` | \`bookmarks\` |
| **gtk-4.0** | \`config/gtk-4.0/\` | \`~/.config/gtk-4.0/\` | \`servers\` |
| **hypr** | \`config/hypr/\` | \`~/.config/hypr/\` | \`hyprpaper.conf,hyprland.conf.bak.2026-04-26-053801 config/monitors-programs.conf,config/generated-theme.conf config/bindings.conf,config/appearance.conf\` |
| **kitty** | \`config/kitty/\` | \`~/.config/kitty/\` | \`kitty.conf,theme.conf\` |
| **nvim** | \`config/nvim/\` | \`~/.config/nvim/\` | \`.gitignore,lazyvim.json .neoconf.json,init.lua LICENSE,nvim-pack-lock.json\` |
| **qt5ct** | \`config/qt5ct/\` | \`~/.config/qt5ct/\` | \`colors/noctalia.conf\` |
| **qt6ct** | \`config/qt6ct/\` | \`~/.config/qt6ct/\` | \`colors/noctalia.conf,qt6ct.conf\` |
| **rofi** | \`config/rofi/\` | \`~/.config/rofi/\` | \`themes/sidetab-nord.rasi,themes/nord.rasi themes/powermenu.rasi,config.rasi powermenu.sh\` |
| **waybar** | \`config/waybar/\` | \`~/.config/waybar/\` | \`config.jsonc,theme.css style.css,mediaplayer.py check_updates.sh\` |
| **wofi** | \`config/wofi/\` | \`~/.config/wofi/\` | \`config,style.css\` |
| **yazi** | \`config/yazi/\` | \`~/.config/yazi/\` | \`yazi.toml\` |
| **.bashrc** | \`home/.bashrc\` | \`~/.bashrc\` | Home dotfile |
| **.gitconfig** | \`home/.gitconfig\` | \`~/.gitconfig\` | Home dotfile |
| **.zshrc** | \`home/.zshrc\` | \`~/.zshrc\` | Home dotfile |

## Full File Tree

```text
config
config/btop
config/btop/btop.conf
config/btop/themes
config/btop/themes/noctalia.theme
config/fastfetch
config/fastfetch/config.jsonc
config/fish
config/fish/config.fish
config/fish/fish_variables
config/gtk-3.0
config/gtk-3.0/bookmarks
config/gtk-4.0
config/gtk-4.0/servers
config/hypr
config/hypr/backup_lua
config/hypr/backup_lua/animations.lua
config/hypr/backup_lua/autostart.lua
config/hypr/backup_lua/binds.lua
config/hypr/backup_lua/decorations.lua
config/hypr/backup_lua/environment.lua
config/hypr/backup_lua/hyprland-gui.lua
config/hypr/backup_lua/hyprland.lua
config/hypr/backup_lua/inputs.lua
config/hypr/backup_lua/misc.lua
config/hypr/backup_lua/monitors.lua
config/hypr/backup_lua/variables.lua
config/hypr/backup_lua/windowrules.lua
config/hypr/backup_lua/workspaces.lua
config/hypr/config
config/hypr/config/appearance.conf
config/hypr/config/autostart.conf
config/hypr/config/bindings.conf
config/hypr/config/environment-rules.conf
config/hypr/config/generated-theme.conf
config/hypr/config/input.conf
config/hypr/config/monitors-programs.conf
config/hypr/config/theme.conf
config/hypr/hyprland.conf
config/hypr/hyprland.conf.bak.2026-04-26-053801
config/hypr/hyprland-gui.conf
config/hypr/hyprland.lua.bak
config/hypr/hyprmod
config/hypr/hyprmod/active_profile
config/hypr/hyprmod/profiles
config/hypr/hyprpaper.conf
config/hypr/scripts
config/hypr/scripts/change_wallpaper.sh
config/hypr/scripts/update-theme.sh
config/kitty
config/kitty/kitty.conf
config/kitty/theme.conf
config/kitty/themes
config/nvim
config/nvim/doc
config/nvim/.gitignore
config/nvim/init.lua
config/nvim/lazy-lock.json
config/nvim/lazyvim.json
config/nvim/LICENSE
config/nvim/lua
config/nvim/lua/config
config/nvim/lua/plugins
config/nvim/.neoconf.json
config/nvim/nvim-pack-lock.json
config/nvim/plugin_backup
config/nvim/README.md
config/nvim/stylua.toml
config/qt5ct
config/qt5ct/colors
config/qt5ct/colors/noctalia.conf
config/qt6ct
config/qt6ct/colors
config/qt6ct/colors/noctalia.conf
config/qt6ct/qt6ct.conf
config/rofi
config/rofi/config.rasi
config/rofi/powermenu.sh
config/rofi/themes
config/rofi/themes/nord.rasi
config/rofi/themes/powermenu.rasi
config/rofi/themes/sidetab-nord.rasi
config/waybar
config/waybar/check_updates.sh
config/waybar/config.jsonc
config/waybar/mediaplayer.py
config/waybar/style.css
config/waybar/theme.css
config/wofi
config/wofi/config
config/wofi/style.css
config/yazi
config/yazi/yazi.toml
home
home/.bashrc
home/.gitconfig
home/.zshrc
```

## Quick Restore

```fish
# Restore ~/.config directories and files
rsync -av ./config/ ~/.config/

# Restore ~/ dotfiles
rsync -av ./home/ ~/
```
