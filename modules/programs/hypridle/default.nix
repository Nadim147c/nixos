{ self, lib, ... }:
let
  inherit (lib.hm.generators) toHyprconf;
  inherit (lib)
    escapeShellArg
    toList
    getExe
    getExe'
    ;
in
{
  perSystem =
    { pkgs, self', ... }:
    {
      packages.hyprlock-restore = pkgs.writeNuApplication {
        name = "hyprlock-restore";
        runtimeInputs = [
          pkgs.hyprland
          self'.packages.control
          self'.packages.hyprlock
        ];
        text = /* nu */ ''
          hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
          ps | find hyprlock | get pid | each {|pid| kill --force $pid}
          control hyprlock
        '';
      };
    };

  flake.modules.nixos.gui =
    { pkgs, system, ... }:
    let
      hyprctl = getExe' pkgs.hyprland "hyprctl";
      pidof = getExe' pkgs.procps "pidof";
      notify-send = getExe' pkgs.libnotify "notify-send";
      hyprlock = getExe self.packages.${system}.hyprlock;
      control = getExe self.packages.${system}.control;
      turn-off-monitor = escapeShellArg ''hl.dsp.dpms("on")'';
      turn-on-monitor = escapeShellArg ''hl.dsp.dpms("off")'';
    in
    {
      packages = toList self.packages.${system}.hyprlock-restore;

      home.systemd.services.hypridle = rec {
        enable = true;
        description = "Hypridle daemon";
        partOf = toList "graphical-session.target";
        after = partOf;
        wantedBy = partOf;
        unitConfig = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        serviceConfig = {
          ExecStart = getExe pkgs.hypridle;
          Restart = "always";
          RestartSec = "10";
        };
      };

      home.xdg.config.files."hypr/hypridle.conf" = {
        generator = attrs: toHyprconf { inherit attrs; };
        value = {
          general = {
            lock_cmd = "${pidof} hyprlock || ${hyprlock}";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "${hyprctl} dispatch ${turn-off-monitor}";
          };
          listener = [
            {
              timeout = 295;
              on-timeout = "${notify-send} 'Locking the session in 5 seconds'";
            }
            {
              timeout = 300;
              on-timeout = "${pidof} hyprlock || ${control} ${hyprlock}";
            }
            {
              timeout = 360;
              on-timeout = "${hyprctl} dispatch ${turn-off-monitor}";
              on-resume = "${hyprctl} dispatch ${turn-on-monitor}";
            }
          ];
        };
      };
    };
}
