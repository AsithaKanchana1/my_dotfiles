local home = os.getenv("HOME") or "/home/asithakanchana"
local terminal = "kitty"
local fileManager = "kitty -e yazi"
local menu = "rofi -show combi -config " .. home .. "/.config/rofi/config.rasi"
local browser = "brave"
local powerMenu = home .. "/.config/rofi/powermenu.sh"

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local function theme_color(value, fallback)
    local hex = value and value:match("rgb%((%x+)%)")
    if hex and #hex == 6 then
        return "0xff" .. hex
    elseif hex and #hex == 8 then
        return "0x" .. hex
    end
    return fallback
end

local color2, color4, background = "0xff322653", "0xff572e5d", "0xff3e2e4f"
local theme = io.open(home .. "/.config/hypr/config/generated-theme.conf", "r")
if theme then
    local contents = theme:read("*a")
    theme:close()
    color2 = theme_color(contents:match("%$color2%s*=%s*([^\n]+)"), color2)
    color4 = theme_color(contents:match("%$color4%s*=%s*([^\n]+)"), color4)
    background = theme_color(contents:match("%$background%s*=%s*([^\n]+)"), background)
end

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("waybar")
    hl.exec_cmd(home .. "/.config/hypr/scripts/change_wallpaper.sh")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd(terminal)
    hl.exec_cmd("swaync")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("GDK_SCALE", "1")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    general = {
        gaps_in = 1,
        gaps_out = { top = 0, right = 1, bottom = 1, left = 1 },
        border_size = 2,
        col = {
            active_border = { colors = { color2, color4 }, angle = 45 },
            inactive_border = background,
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    animations = {
        enabled = true,
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        mouse_refocus = false,
        numlock_by_default = true,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.curve("rapid", { type = "bezier", points = { { 0.0, 0.5 }, { 0.0, 1.0 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 0.8, bezier = "rapid", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.8, bezier = "rapid", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 0.5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 0.8, bezier = "rapid", style = "slide" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("nautilus --new-window"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("libreoffice --writer"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd(powerMenu))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind("ALT + Tab", hl.dsp.group.next())
hl.bind("ALT + SHIFT + Tab", hl.dsp.group.prev())
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 (monitor_h-120)",
    float = true,
})

hl.window_rule({
    name = "nmtui-float",
    match = { class = "^(floating_nmtui)$" },
    float = true,
    center = true,
    size = { 600, 400 },
})

hl.window_rule({
    name = "microsoft-office-apps",
    match = { title = "^(Microsoft .*)$" },
    float = true,
    size = { 1200, 800 },
    center = true,
})

hl.window_rule({
    name = "nmtui-waybar-float",
    match = { class = "^(nmtui-float)$" },
    float = true,
    center = true,
    size = { 700, 500 },
})

hl.window_rule({ match = { class = "^(Zoom Workplace)$", title = "^(as_toolbar)$" }, float = true })
hl.window_rule({ match = { class = "^(zoom)$", title = "^(as_toolbar)$" }, float = true })
hl.window_rule({ match = { class = "^(Zoom Workplace)$", title = "^(as_toolbar)$" }, pin = true })
hl.window_rule({ match = { class = "^(zoom)$", title = "^(as_toolbar)$" }, pin = true })
hl.window_rule({ match = { class = "^(Zoom Workplace)$", title = "^(as_toolbar)$" }, border_size = 0 })
hl.window_rule({ match = { class = "^(zoom)$", title = "^(as_toolbar)$" }, border_size = 0 })
hl.window_rule({ match = { title = "^(as_toolbar)$" }, animation = "none" })
