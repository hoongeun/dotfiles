local hy3 = hl.plugin and hl.plugin.hy3


local mod = "SUPER"
local term = "ghostty"
local lock = "pidof hyprlock || hyprlock"

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1",
})

local gpu = os.getenv("HOME") .. "/.config/hypr/gpu.lua"
if io.open(gpu) then dofile(gpu) end

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("XCURSOR_SIZE", "24")

hl.curve("expo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("soft", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4,
    bezier = "expo",
    style = "popin 94%",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2.5,
    bezier = "soft",
    style = "popin 94%",
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 4,
    bezier = "expo",
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3,
    bezier = "soft",
})
hl.animation({
    leaf = "fadeDim",
    enabled = true,
    speed = 4,
    bezier = "soft",
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 5,
    bezier = "soft",
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 4,
    bezier = "expo",
    style = "slidefade 8%",
})
hl.animation({
    leaf = "specialWorkspace",
    enabled = true,
    speed = 4,
    bezier = "expo",
    style = "slidefadevert 12%",
})
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 3,
    bezier = "expo",
    style = "fade",
})



-- TODO: manual review — plugin section ''. The new Lua API exposes plugins via hl.plugin.<name>(...) — wire up per the plugin's docs.
--[[
  hy3 { ... }
]]

hl.workspace_rule({
    workspace = "w[tv1]",
    gaps_out = 0,
    gaps_in = 0,
})

hl.workspace_rule({
    workspace = "f[1]",
    gaps_out = 0,
    gaps_in = 0,
})

hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.3,
})

hl.layer_rule({
    match = { namespace = "notifications" },
    blur = true,
    ignore_alpha = 0.3,
})

hl.window_rule({
    match = {
        float = false,
        workspace = "w[tv1]",
    },
    border_size = 0,
    rounding = 0,
})

hl.window_rule({
    match = {
        float = false,
        workspace = "f[1]",
    },
    border_size = 0,
    rounding = 0,
})

hl.window_rule({
    match = {
        title = "^(alsamixer)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(pavucontrol)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(org\\.gnome\\.Calculator)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(org\\.gnome\\.Nautilus)$",
    },
    float = true,
    size = "(monitor_w*0.6) (monitor_h*0.65)",
    center = true,
})

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + D", hl.dsp.exec_cmd("$HOME/.local/bin/vicinae toggle"))
hl.bind(mod .. " + F2", hl.dsp.exec_cmd("brave-browser"))
hl.bind(mod .. " + F3", hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + CTRL + M", hl.dsp.exec_cmd(term .. " -e alsamixer"))
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%F_%H-%M-%S).png"))
hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd("killall dunst; dunst & notify-send 'restart dunst'"), { release = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })



hl.bind(mod .. " + B", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + SHIFT + B", hl.dsp.window.move({ workspace = "previous" }))

hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.pin())
hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd("/home/linuxbrew/.linuxbrew/bin/nu --no-config-file $HOME/.config/hypr/showcase.nu"))
hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
hl.bind(mod .. " + minus", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mod .. " + CTRL + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + CTRL + Left", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mod .. " + CTRL + 1", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind(mod .. " + CTRL + 2", hl.dsp.window.move({ workspace = 2, follow = false }))
hl.bind(mod .. " + CTRL + 3", hl.dsp.window.move({ workspace = 3, follow = false }))
hl.bind(mod .. " + CTRL + 4", hl.dsp.window.move({ workspace = 4, follow = false }))
hl.bind(mod .. " + CTRL + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
hl.bind(mod .. " + CTRL + 6", hl.dsp.window.move({ workspace = 6, follow = false }))
hl.bind(mod .. " + CTRL + 7", hl.dsp.window.move({ workspace = 7, follow = false }))
hl.bind(mod .. " + CTRL + 8", hl.dsp.window.move({ workspace = 8, follow = false }))
hl.bind(mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize())

hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("zenity --question --text 'Exit Hyprland? This ends your Wayland session.' && hyprctl dispatch exit"))

hl.bind(mod .. " + L", hl.dsp.exec_cmd(lock))
hl.bind(mod .. " + 0", hl.dsp.submap("system"))
hl.define_submap("system", function()
    hl.bind("L", hl.dsp.exec_cmd(lock))
    hl.bind("L", hl.dsp.submap("reset"))
    hl.bind("E", hl.dsp.exit())
    hl.bind("S", hl.dsp.exec_cmd("systemctl suspend"))
    hl.bind("S", hl.dsp.submap("reset"))
    hl.bind("R", hl.dsp.exec_cmd("systemctl reboot"))
    hl.bind("SHIFT + S", hl.dsp.exec_cmd("systemctl poweroff"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
end)

hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("J", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("semicolon", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("Left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
    hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })
    hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
    hl.bind("Right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
end)

hl.config({
    input = {
        kb_options = "ctrl:nocaps",
        repeat_delay = 300,
        repeat_rate = 50,
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
    },
    general = {
        gaps_in = 3,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border = "rgba(cdd6f4aa)",
            inactive_border = "rgba(cdd6f40f)",
        },
        layout = hy3 and "hy3" or "dwindle",
    },
    decoration = {
        rounding = 10,
        rounding_power = 2.5,
        active_opacity = 1.0,
        inactive_opacity = 0.94,
        dim_inactive = true,
        dim_strength = 0.06,
        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            noise = 0.015,
            contrast = 0.9,
            brightness = 0.8,
            vibrancy = 0.15,
            popups = true,
        },
        shadow = {
            enabled = true,
            range = 24,
            render_power = 3,
            offset = "0 6",
            color = "rgba(00000055)",
            color_inactive = "rgba(00000022)",
        },
    },
    animations = {
        enabled = true,
    },
    -- Frosted bar and notifications; ignore_alpha keeps blur off fully transparent edges.
    binds = {
        workspace_back_and_forth = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        focus_on_activate = true,
    },
    -- No gaps or border when a workspace has one tiled window.
    -- hy3: i3-style containers; H/V wrap the focused window in a new container.
})

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("swaybg -i $HOME/.config/hypr/wallpaper.jpg -m fill")
    hl.exec_cmd("waybar > $HOME/.cache/waybar.log 2>&1")
    hl.exec_cmd("$HOME/.local/bin/vicinae server")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("sh $HOME/.config/hypr/start-hy3.sh")
end)


if hy3 then
    hl.bind(mod .. " + J", hy3.move_focus("l"))
    hl.bind(mod .. " + K", hy3.move_focus("d"))
    hl.bind(mod .. " + semicolon", hy3.move_focus("r"))
    hl.bind(mod .. " + Left", hy3.move_focus("l"))
    hl.bind(mod .. " + Down", hy3.move_focus("d"))
    hl.bind(mod .. " + Up", hy3.move_focus("u"))
    hl.bind(mod .. " + Right", hy3.move_focus("r"))
    hl.bind(mod .. " + SHIFT + J", hy3.move_window("l"))
    hl.bind(mod .. " + SHIFT + K", hy3.move_window("d"))
    hl.bind(mod .. " + SHIFT + L", hy3.move_window("u"))
    hl.bind(mod .. " + SHIFT + semicolon", hy3.move_window("r"))
    hl.bind(mod .. " + SHIFT + Left", hy3.move_window("l"))
    hl.bind(mod .. " + SHIFT + Down", hy3.move_window("d"))
    hl.bind(mod .. " + SHIFT + Up", hy3.move_window("u"))
    hl.bind(mod .. " + SHIFT + Right", hy3.move_window("r"))
    hl.bind(mod .. " + H", hy3.make_group("h"))
    hl.bind(mod .. " + V", hy3.make_group("v"))
    hl.bind(mod .. " + Q", hy3.change_group("opposite"))
    hl.bind(mod .. " + E", hy3.change_group("opposite"))
    hl.bind(mod .. " + W", hy3.change_group("toggletab"))
    hl.bind(mod .. " + S", hy3.change_group("toggletab"))
    hl.bind(mod .. " + A", hy3.change_focus("raise"))
    hl.bind(mod .. " + SHIFT + A", hy3.change_focus("lower"))
    hl.bind(mod .. " + Tab", hy3.focus_tab({ direction = "r", wrap = true }))
end
