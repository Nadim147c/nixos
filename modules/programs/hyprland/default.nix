{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (builtins) attrNames readFile toJSON;
  inherit (lib) mkOption optionalString;
  inherit (lib.fixedPoints) fix;
  inherit (lib.generators) toLua;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules)
    mkIf
    mkAfter
    mkBefore
    mkMerge
    ;
  inherit (lib.strings) join concatMapAttrsStringSep concatMapStringsSep;
  inherit (lib.types) submodule listOf;
  inherit (lib.x) opt;
in
{
  perSystem = { pkgs, ... }: {
    packages.hyprland = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;
      filesToExclude = singleton "share/wayland-sessions/hyprland-uwsm.desktop";
      passthru.providedSessions = singleton "hyprland";
    };
  };

  flake.modules.hjem.base =
    { config, ... }:
    let
      cfg = config.programs.hyprland;

      mapList = concatMapStringsSep "\n";
      mapAttr = concatMapAttrsStringSep "\n";

      binds = mapList (
        {
          exec,
          keys,
          opts,
          ...
        }:
        "hl.bind(${join " + " keys |> toJSON}, hl.dsp.exec_cmd(${toJSON exec}), ${toLua { } opts})"
      ) cfg.programs;

      autostart = mapList (
        { exec, autostart, ... }: optionalString autostart "hl.dispatch(hl.dsp.exec_cmd(${toJSON exec}))"
      ) cfg.programs;

      windowRules = mapList (attrs: "hl.window_rule(${toLua { } attrs})") cfg.windowRules;
      layerRules = mapList (attrs: "hl.layer_rule(${toLua { } attrs})") cfg.layerRules;
      luaModules = mapList readFile cfg.luaModules;

      envs = mapAttr (name: value: "hl.env(${toJSON name}, ${toJSON value})") cfg.env;
      displays = mapAttr (
        output: value:
        let
          inherit (value)
            enable
            width
            height
            refreshRate
            x
            y
            ;

          hlDisplay = {
            disabled = !enable;
            output = output;
            mode = "${toString width}x${toString height}@${toString refreshRate}";
            position = "${toString x}x${toString y}";
          }
          // value.extra;
        in
        "hl.monitor(${toLua { } hlDisplay})"
      ) cfg.displays;

      events = mapAttr (name: body: ''
        hl.on(${toJSON name}, function()
         ${body}
        end)
      '') cfg.events;
    in
    {
      options.programs.hyprland = {
        enable = opt.bool true;
        env = opt.attrs.str { };
        displays = opt.attrs.recursive { };
        windowRules = opt.list.recursive [ ];
        layerRules = opt.list.recursive [ ];
        events = opt.attrs.block { };
        luaConfig = opt.block "";
        luaModules = opt.list.path [ ];
        programs = mkOption {
          type = listOf (submodule {
            options = {
              autostart = opt.bool false;
              exec = opt.line "";
              keys = opt.list.line [ ];
              opts = opt.attrs.recursive { };
            };
          });
        };
      };

      config = mkIf cfg.enable {
        programs.hyprland.events."hyprland.start" = autostart;
        programs.hyprland.luaConfig = mkMerge [
          (mkBefore envs)
          (mkBefore displays)
          (mkBefore binds)
          (mkBefore windowRules)
          (mkBefore layerRules)
          (mkAfter luaModules)
          (mkAfter events)
        ];
        xdg.config.files."hypr/hyprland.lua".text = cfg.luaConfig;
      };
    };

  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      inherit (self.packages.${system})
        qs-toggle
        mpvpaper-send-ipc
        dolphin
        discord
        hyprscreenshot
        helium
        kitty
        kopuz
        control
        ;
    in
    {
      systemd.user.targets = {
        hyprland-session = {
          unitConfig = {
            Description = "Hyprland compositor session";
            BindsTo = singleton "graphical-session.target";
            Wants = singleton "graphical-session-pre.target";
            After = singleton "graphical-session-pre.target";
          };
        };
        tray = {
          unitConfig = {
            Description = "System tray target";
            Requires = singleton "graphical-session-pre.target";
          };
        };
      };

      hj.systemd.paths.hyprland-reload-config = fix (final: {
        enable = true;
        description = "Watch for hyprland config change";
        partOf = singleton "graphical-session.target";
        wantedBy = final.partOf;
        pathConfig = {
          PathChanged = "%E/hypr";
          Unit = "hyprland-reload-config.service";
        };
      });

      hj.systemd.services.hyprland-reload-config = {
        enable = true;
        description = "Reload hyprland on config change";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${getExe' config.programs.hyprland.package "hyprctl"} reload";
        };
      };

      programs.hyprland = {
        enable = true;
        package = self.packages.${system}.hyprland;
        xwayland.enable = true;
        withUWSM = false;
      };

      packages = with pkgs; [
        hyprshutdown
        playerctl
        wl-clipboard
      ];

      hj.programs.hyprland = fix (final: {
        inherit (config) displays;
        enable = true;
        luaModules = [
          ./animations.lua
          ./hyprland.lua
        ];
        programs =
          let
            launcher = getExe control;
            makeProgram = keys: exec: {
              inherit keys exec;
              autostart = true;
            };
            makeBind = keys: exec: {
              inherit keys exec;
              autostart = true;
            };
            lockedAndRepeat = {
              locked = true;
              repeating = true;
            };
            wpctl = getExe' pkgs.wireplumber "wpctl";
            playerctl = getExe' pkgs.playerctl "playerctl";
            brightnessctl = getExe pkgs.brightnessctl;
          in
          [
            (makeProgram [ "SUPER" "B" ] "${launcher} --memory=2G --cpu=200% ${getExe helium}")
            (makeProgram [ "SUPER" "D" ] "${launcher} --memory=1G --cpu=80% ${getExe discord}")
            (makeProgram [ "SUPER" "Q" ] "${launcher} ${getExe kitty}")
            (makeProgram [ "SUPER" "M" ] "${launcher} ${getExe kopuz}")

            (makeBind [ "SUPER" "E" ] "${launcher} ${getExe' dolphin "dolphin"}")
            (makeBind [ "SUPER" "V" ] "${getExe qs-toggle} clipboard toggle")
            (makeBind [ "SUPER" "SPACE" ] "${getExe qs-toggle} clipboard launcher")
            (makeBind [ "SUPER" "PRINT" ] "${getExe hyprscreenshot} screen")
            (makeBind [ "PRINT" ] "${getExe hyprscreenshot} region")

            {
              keys = [ "XF86AudioRaiseVolume" ];
              exec = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86AudioLowerVolume" ];
              exec = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86AudioMute" ];
              exec = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86AudioMicMute" ];
              exec = "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86MonBrightnessUp" ];
              exec = "${brightnessctl} -e4 -n2 set 5%+";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86MonBrightnessDown" ];
              exec = "${brightnessctl} -e4 -n2 set 5%-";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86AudioNext" ];
              exec = "${playerctl} next";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86AudioPause" ];
              exec = "${playerctl} pause";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86AudioPlay" ];
              exec = "${playerctl} play-pause";
              opts = lockedAndRepeat;
            }
            {
              keys = [ "XF86AudioPrev" ];
              exec = "${playerctl} previous";
              opts = lockedAndRepeat;
            }
          ];

        events =
          let
            mpvpaperToggle = /* lua */ ''
              local workspace = hl.get_active_workspace()
              if workspace == nil then
                return
              end
              local windows = hl.get_windows({ workspace = workspace.id })
              local command = " 'set pause no'"
              for _, window in pairs(windows) do
                if (not window.floating) or (window.fullscreen == 1) then
                  command = " 'set pause yes'"
                end
              end
              hl.dispatch(hl.dsp.exec_cmd(${getExe mpvpaper-send-ipc |> toJSON} .. command))
            '';
          in
          {
            "window.active" = mpvpaperToggle;
            "window.class" = mpvpaperToggle;
            "window.fullscreen" = mpvpaperToggle;
            "window.move_to_workspace" = mpvpaperToggle;
            "workspace.active" = mpvpaperToggle;
            "hyprland.start" =
              let
                envNames = attrNames final.env |> join " " |> toJSON;
              in
              /* lua */ ''
                hl.dispatch(hl.dsp.exec_cmd("systemctl --user import-environment " .. ${envNames}))
                hl.dispatch(hl.dsp.exec_cmd("dbus-update-activation-environment --systemd " .. ${envNames}))
                hl.dispatch(hl.dsp.exec_cmd(${
                  toJSON /* bash */ ''
                    systemctl --user stop  hyprland-session.target
                    systemctl --user start hyprland-session.target
                  ''
                }))
              '';
          };

        env = {
          CLUTTER_BACKEND = "wayland";
          SDL_VIDEODRIVER = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          GDK_BACKEND = "wayland,x11,*";
          inherit (config.environment.sessionVariables)
            XCURSOR_SIZE
            XCURSOR_THEME
            HYPRCURSOR_SIZE
            HYPRCURSOR_THEME
            GTK_THEME
            QT_QPA_PLATFORM
            QT_AUTO_SCREEN_SCALE_FACTOR
            QT_WAYLAND_DISABLE_WINDOWDECORATION
            QT_QPA_PLATFORMTHEME
            ;
        };
      });
    };
}
