-- Animation profile converted from legacy hyprland.conf

hl.curve("rapid", { type = "bezier", points = { { 0.0, 0.5 }, { 0.0, 1.0 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "rapid" })
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "rapid", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "rapid", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "rapid", style = "slide" })
