local main_mod = "SUPER"

local function get_binds(...)
  local args = { ... }
  return table.concat(args, " + ")
end

hl.window_rule({
  name = "kitty workspace 1",
  match = { class = "^(kitty)$" },
  workspace = "1 silent",
})
hl.window_rule({
  name = "browser workspace 2",
  match = { class = "^(zen-(beta|browser)|[hH]elium)$" },
  workspace = "2 silent",
})
hl.window_rule({
  name = "discord workspace 3",
  match = { class = "^(discord|vesktop|equibop)$" },
  workspace = "3 silent",
})
hl.window_rule({
  name = "music workspace 4",
  match = { class = "^(kopuz)$" },
  workspace = "4 silent",
})

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

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(get_binds(main_mod, "X"), hl.dsp.window.close())
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

hl.bind(get_binds(main_mod, "H"), hl.dsp.focus({ direction = "l" }))
hl.bind(get_binds(main_mod, "J"), hl.dsp.focus({ direction = "d" }))
hl.bind(get_binds(main_mod, "K"), hl.dsp.focus({ direction = "u" }))
hl.bind(get_binds(main_mod, "L"), hl.dsp.focus({ direction = "r" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(get_binds(main_mod, "mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(get_binds(main_mod, "mouse:273"), hl.dsp.window.resize(), { mouse = true })

hl.layer_rule({
  name = "quickshell",
  match = { namespace = "^quickshell:.*$" },
  blur = true,
  ignore_alpha = 0.5,
})

hl.window_rule({
  name = "Low Opacity",
  match = { title = "^(kitty|kopuz)$" },
  opacity = "0.85 0.70",
})

hl.window_rule({
  name = "Picture in Picture windows",
  match = { title = "^.*[Pp]icture[ -][Ii]n[ -][Pp]icture.*$" },
  float = true,
  pin = true,
  rounding = 7,
  opacity = "1 1",
  move = { "monitor_w-(monitor_w/4)-10", "monitor_h-(monitor_h/4)-10" },
  size = { "monitor_w/4", "monitor_h/4" },
})
