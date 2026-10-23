-- Hyprland on a stock Galaxy Tab S9 FE: Lindroid stack, shown through Termux:X11.
-- Catppuccin Mocha by default; accents follow the wallpaper (see theme below). Effects are kept balanced: every frame takes an extra GPU copy into
-- Termux:X11, so blur is limited to the bar and launcher and windows stay opaque.

local mocha = {
    rosewater = "f5e0dc", flamingo = "f2cdcd", pink = "f5c2e7", mauve = "cba6f7",
    red = "f38ba8", maroon = "eba0ac", peach = "fab387", yellow = "f9e2af",
    green = "a6e3a1", teal = "94e2d5", sky = "89dceb", sapphire = "74c7ec",
    blue = "89b4fa", lavender = "b4befe", text = "cdd6f4", subtext0 = "a6adc8",
    overlay0 = "6c7086", surface1 = "45475a", surface0 = "313244",
    base = "1e1e2e", mantle = "181825", crust = "11111b",
}

-- Accent colours from the wallpaper: ~/.local/bin/wallpaper has matugen rewrite colors.lua, then
-- reloads. Mocha stands in until a wallpaper has been applied.
local ok, theme = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/colors.lua")
if not ok then
    theme = { accent = mocha.mauve, accent2 = mocha.blue, inactive = mocha.surface0 }
end

local function rgba(hex, alpha)
    return "rgba(" .. hex .. (alpha or "ff") .. ")"
end

-- Apps run through app-env: Hyprland's libhybris environment is for the compositor only
local app      = os.getenv("HOME") .. "/.local/bin/app-env "
local bin      = os.getenv("HOME") .. "/.local/bin/"
-- foot, not kitty: with no GPU for apps, kitty redraws its whole window through llvmpipe on every
-- key (~100 ms); foot renders only changed cells on the CPU (~5 ms)
local terminal = app .. "foot"
local menu     = app .. "rofi -show drun"
local mainMod  = "SUPER"
local alt      = "ALT"

-- The evdi output's mode follows Termux:X11: lindroid-uevent applies changes live and saves the
-- mode, since aquamarine's cached "preferred" mode goes stale after a resize.
local function current_mode()
    local f = io.open((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/lindroid-mode")
    local mode = f and f:read("*l")
    if f then f:close() end
    return (mode and mode ~= "") and mode or "preferred"
end

hl.monitor({
    output   = "",
    mode     = current_mode(),
    position = "auto",
    scale    = 1,
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.on("hyprland.start", function ()
    -- Termux:X11's touch, mouse and keyboard, delivered through create-disp
    -- (kept alive: without it Termux:X11 has no way to reach the session)
    hl.exec_cmd("sh -c 'while :; do /opt/hybris/bin/lindroid-input 2>>/tmp/input.log; sleep 1; done'")
    -- awww draws on the CPU (hyprpaper's EGL client path crashes under libhybris); restores the
    -- last wallpaper picked with Super+Shift+Space
    hl.exec_cmd(app .. bin .. "wallpaper restore")
    hl.exec_cmd(app .. "waybar")
    hl.exec_cmd(app .. "mako")
    -- Android and Linux clipboards kept in sync (droid-window)
    hl.exec_cmd(app .. "droid-window --clip-sync")
    -- Refresh the Android apps listed in the launcher
    hl.exec_cmd(app .. "droid-apps-sync")
    hl.exec_cmd(terminal)
end)

hl.config({
    general = {
        -- i3: gaps inner 12, outer 5
        gaps_in     = 6,
        gaps_out    = 11,
        border_size = 2,
        col = {
            active_border   = { colors = { rgba(theme.accent), rgba(theme.accent2) }, angle = 45 },
            inactive_border = rgba(theme.inactive),
        },
        -- Fingers are less precise than a mouse; let window edges be grabbed
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.17,
        },
    },

    animations = {
        enabled = true,
    },

    -- The frame handed to Termux:X11 has no cursor plane; draw the cursor into it
    cursor = {
        no_hardware_cursors = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },

    input = {
        kb_layout    = "us",
        -- i3: focus_follows_mouse no
        follow_mouse = 0,
        sensitivity  = 0,
        -- Termux:X11 scrolling felt weak; applies to Android windows too
        scroll_factor = 2.0,
    },

    dwindle = {
        preserve_split = true,
    },

    -- aquamarine logs several lines per frame on this output (no multi-GPU renderer); the log
    -- grew to tens of MB and cost CPU. Re-enable when debugging.
    debug = {
        disable_logs = true,
    },
})

-- Snappy: short durations (speed is in tenths of a second) on fast-settling curves
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},  {0.32, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},  {0.1, 1}  } })

hl.animation({ leaf = "global",     enabled = true, speed = 4,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 3,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 2.2, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 2,   bezier = "easeOutQuint", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1,   bezier = "quick",        style = "popin 92%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 1.5, bezier = "quick" })
hl.animation({ leaf = "layers",     enabled = true, speed = 2,   bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 2,   bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 1,   bezier = "quick",        style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.8, bezier = "easeOutQuint", style = "slide" })

-- Blur only behind the bar, the launcher and notifications
hl.layer_rule({ name = "blur-waybar", match = { namespace = "^waybar$" },        blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "blur-rofi",   match = { namespace = "^rofi$" },          blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "blur-mako",   match = { namespace = "^notifications$" }, blur = true, ignore_alpha = 0.2 })

-- i3 keybinds ($mod = Super, with the Alt duplicates the i3 config had)
for _, mod in ipairs({ mainMod, alt }) do
    hl.bind(mod .. " + Return",      hl.dsp.exec_cmd(terminal))
    hl.bind(mod .. " + D",           hl.dsp.exec_cmd(menu))
    hl.bind(mod .. " + SHIFT + Q",   hl.dsp.window.close())
    for i = 1, 9 do
        hl.bind(mod .. " + " .. i,   hl.dsp.focus({ workspace = i }))
    end
end

hl.bind(mainMod .. " + SPACE",       hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Tab",         hl.dsp.exec_cmd(app .. bin .. "window-switcher"))
-- Wallpaper picker; the theme follows the chosen wallpaper
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd(app .. bin .. "wallpaper pick"))

local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(directions) do
    hl.bind(mainMod .. " + " .. key,               hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. key,       hl.dsp.window.move({ direction = dir }))
end
for _, dir in ipairs({ "left", "down", "up", "right" }) do
    hl.bind(mainMod .. " + " .. dir,               hl.dsp.focus({ direction = dir }))
end

-- split h / split v / layout toggle split
hl.bind(mainMod .. " + B",           hl.dsp.layout("preselect r"))
hl.bind(mainMod .. " + V",           hl.dsp.layout("preselect d"))
hl.bind(mainMod .. " + E",           hl.dsp.layout("togglesplit"))
-- stacking / tabbed: Hyprland's tabbed groups
hl.bind(mainMod .. " + S",           hl.dsp.group.toggle())
hl.bind(mainMod .. " + W",           hl.dsp.group.toggle())
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + F",   hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + SPACE",  hl.dsp.window.cycle_next())

for i = 1, 9 do
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + SHIFT + C",   hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + R",   hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + E",   hl.dsp.exit())
-- Freeze the Linux session; a touch, key press or reopening Termux:X11 wakes it
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd(bin .. "lindroid-sleep"))

-- mode "resize"
hl.define_submap("resize", function ()
    hl.bind("h", hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
    hl.bind("l", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)
hl.bind(mainMod .. " + R",           hl.dsp.submap("resize"))

-- Android Back for the focused Android window (no hardware Back key over Termux:X11)
hl.bind(mainMod .. " + BackSpace",   hl.dsp.exec_cmd(app .. "droid-back"))

hl.bind("Print",                     hl.dsp.exec_cmd(app .. bin .. "screenshot"))
hl.bind(mainMod .. " + SHIFT + S",   hl.dsp.exec_cmd(app .. bin .. "screenshot region"))

-- floating_modifier $mod
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- for_window rules
hl.window_rule({ name = "float-pavucontrol", match = { class = "^(org.pulseaudio.pavucontrol|pavucontrol)$" }, float = true })
