-- Window rules converted from legacy hyprland.conf

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
    move = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name = "nmtui-float",
    match = { class = "^(floating_nmtui)$" },
    float = true,
    center = true,
    size = { "600", "400" },
})

hl.window_rule({
    name = "microsoft-office-apps",
    match = { title = "^(Microsoft .*)$" },
    float = true,
    center = true,
    size = { "1200", "800" },
})

hl.window_rule({
    name = "nmtui-waybar-float",
    match = { class = "^(nmtui-float)$" },
    float = true,
    center = true,
    size = { "700", "500" },
})

-- Zoom share toolbar handling
hl.window_rule({ match = { class = "^(Zoom Workplace)$", title = "^(as_toolbar)$" }, float = true, pin = true })
hl.window_rule({ match = { class = "^(zoom)$", title = "^(as_toolbar)$" }, float = true, pin = true })
hl.window_rule({ match = { class = "^(Zoom Workplace)$", title = "^(as_toolbar)$" }, border_size = 0 })
hl.window_rule({ match = { class = "^(zoom)$", title = "^(as_toolbar)$" }, border_size = 0 })
hl.window_rule({ match = { title = "^(as_toolbar)$" }, animation = "none" })
