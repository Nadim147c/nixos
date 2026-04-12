local main_mod = "SUPER" -- Sets "Windows" key as main modifier

local displays = require("displays")
local programs = require("programs")
local envs = require("envs")

for _, value in pairs(displays) do
  hl.monitor(value)
end

for key, value in pairs(envs) do
  hl.env(key, value)
end

-- Programs
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(programs.file_manager))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(main_mod .. " + Q", hl.dsp.exec_cmd(programs.terminal))
hl.bind(main_mod .. " + D", hl.dsp.exec_cmd(programs.discord))
hl.window_rule({
  name = "kitty workspace 1",
  match = { class = "^(kitty)$" },
  workspace = "1 silent",
})
hl.window_rule({
  name = "browser workspace 2",
  match = { class = "^(zen-(beta|browser))$" },
  workspace = "2 silent",
})
hl.window_rule({
  name = "discord workspace 3",
  match = { class = "^(discord|vesktop|equibop)$" },
  workspace = "3 silent",
})

hl.on("hyprland.start", function()
  hl.dsp.exec_cmd(programs.terminal)
  hl.dsp.exec_cmd(programs.browser)
  hl.dsp.exec_cmd(programs.discord)
end)

hl.config({
  master = {
    new_status = "master",
  },
  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },

  input = {
    kb_layout = "us,bd",
    kb_variant = ",probhat",
    numlock_by_default = true,
    follow_mouse = 1,
    mouse_refocus = false,
    sensitivity = 0,
    touchpad = {
      natural_scroll = false,
    },
  },

  cursor = {
    no_warps = true,
    sync_gsettings_theme = true,
  },

  misc = {
    disable_autoreload = true,
    disable_hyprland_logo = true,
    disable_watchdog_warning = true,
    font_family = "JetBrainsMono Nerd font",
    force_default_wallpaper = false,
  },

  general = {
    gaps_in = 2,
    gaps_out = 5,
    border_size = 2,
    -- ["col.active_border"] = "$primary",
    -- ["col.inactive_border"] = "$outline",
    layout = "dwindle",
    resize_on_border = true,
  },

  decoration = {
    rounding = 10,
    inactive_opacity = 0.85,
    active_opacity = 0.90,
    fullscreen_opacity = 1.0,

    blur = {
      enabled = true,
      size = 10,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
      popups = true,
    },

    shadow = {
      enabled = false,
      -- color = "$shadow",
    },
  },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

---------------------
---- KEYBINDINGS ----
---------------------

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(main_mod .. " + X", hl.dsp.window.close())
-- hl.bind(
--   main_mod .. " + M",
--   hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
-- )
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind(main_mod .. " + R", hl.dsp.exec_cmd(menu))
-- hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(main_mod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
-- hl.bind(main_mod .. " + left", hl.dsp.focus({ direction = "left" }))
-- hl.bind(main_mod .. " + right", hl.dsp.focus({ direction = "right" }))
-- hl.bind(main_mod .. " + up", hl.dsp.focus({ direction = "up" }))
-- hl.bind(main_mod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 8 do
  local key = i
  hl.bind("F" .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(main_mod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- -- Laptop multimedia keys for volume and LCD brightness
-- hl.bind(
--   "XF86AudioRaiseVolume",
--   hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
--   { locked = true, repeating = true }
-- )
-- hl.bind(
--   "XF86AudioLowerVolume",
--   hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
--   { locked = true, repeating = true }
-- )
-- hl.bind(
--   "XF86AudioMute",
--   hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
--   { locked = true, repeating = true }
-- )
-- hl.bind(
--   "XF86AudioMicMute",
--   hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
--   { locked = true, repeating = true }
-- )
-- hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
--
-- -- Requires playerctl
-- hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
-- hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
--
-- hl.window_rule({
--   name = "suppress-maximize-events",
--   match = { class = ".*" },
--
--   suppress_event = "maximize",
-- })
--
-- hl.window_rule({
--   name = "fix-xwayland-drags",
--   match = {
--     class = "^$",
--     title = "^$",
--     xwayland = true,
--     float = true,
--     fullscreen = false,
--     pin = false,
--   },
--   no_focus = true,
-- })
--
-- -- Hyprland-run windowrule
-- hl.window_rule({
--   name = "move-hyprland-run",
--   match = { class = "hyprland-run" },
--
--   move = "20 monitor_h-120",
--   float = true,
-- })
