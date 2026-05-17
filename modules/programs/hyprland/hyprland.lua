-- Sets "Windows" key as main modifier
local main_mod = "SUPER"

local function get_binds(...)
  local args = { ... }
  return table.concat(args, " + ")
end

local displays = require("displays")
local programs = require("programs")
local envs = require("envs")

hl.dispatch(hl.dsp.exec_cmd(programs.uwsm .. " finalize"))

for _, value in pairs(displays) do
  hl.monitor(value)
end

for key, value in pairs(envs) do
  hl.env(key, value)
end

-- Programs
hl.bind(get_binds(main_mod, "E"), hl.dsp.exec_cmd(programs.file_manager))
hl.bind(get_binds(main_mod, "Q"), hl.dsp.exec_cmd(programs.terminal))
hl.bind(get_binds(main_mod, "B"), hl.dsp.exec_cmd(programs.browser))
hl.bind(get_binds(main_mod, "D"), hl.dsp.exec_cmd(programs.discord))
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
  hl.dispatch(hl.dsp.exec_cmd(programs.terminal))
  hl.dispatch(hl.dsp.exec_cmd(programs.browser))
  hl.dispatch(hl.dsp.exec_cmd(programs.discord))
end)

hl.on("window.urgent", function(w)
  if w ~= nil and w.workspace ~= nil then
    hl.dispatch(hl.dsp.focus({ workspace = w.workspace.id }))
  end
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
hl.bind(get_binds(main_mod, "X"), hl.dsp.window.close())
hl.bind(get_binds(main_mod, "V"), hl.dsp.exec_cmd(programs.qs_toggle .. " clipboard toggle"))
hl.bind(get_binds(main_mod, "SPACE"), hl.dsp.exec_cmd(programs.qs_toggle .. " launcher toggle"))
hl.bind(get_binds(main_mod, "F"), hl.dsp.window.float())
hl.bind(get_binds(main_mod, "SHIFT", "F"), hl.dsp.window.fullscreen())

for i = 1, 8 do
  local key = "F" .. i
  hl.bind(get_binds(key), hl.dsp.focus({ workspace = i }))
  hl.bind(get_binds(main_mod, key), hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(get_binds(main_mod, "mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(get_binds(main_mod, "mouse_up"), hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(get_binds(main_mod, "mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(get_binds(main_mod, "mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- -- Laptop multimedia keys for volume and LCD brightness
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd(programs.wpctl .. " set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd(programs.wpctl .. " set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd(programs.wpctl .. " set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd(programs.wpctl .. " set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true }
)
-- hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(programs.playerctl .. " next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(programs.playerctl .. " pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(programs.playerctl .. " play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(programs.playerctl .. " previous"), { locked = true })
--

hl.layer_rule({
  name = "quickshell",
  match = { namespace = "^quickshell:.*$" },
  blur = true,
  ignore_alpha = 0.5,
})

hl.window_rule({
  name = "Picture in Picture windows",
  match = { title = "^.*[Pp]icture[ -][Ii]n[ -][Pp]icture.*$" },
  float = true,
  pin = true,
  rounding = 7,
  opacity = "1 1",
  move = { "monitor_w-window_w-10", "monitor_h-window_h-10" },
  size = { "monitor_w/4", "monitor_h/4" },
})
