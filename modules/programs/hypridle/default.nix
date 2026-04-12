{ self, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      inherit (lib) getExe';
      hyprctl = getExe' pkgs.hyprland "hyprctl";
      pidof = getExe' pkgs.procps "pidof";
      xargs = getExe' pkgs.findutils "xargs";
    in
    {
      packages.hyprlock-restore = pkgs.writeShellScriptBin "hyprlock-restore" ''
        ${hyprctl} --instance 0 'keyword misc:allow_session_lock_restore 1'
        ${pidof} hyprlock | ${xargs} -r kill -9 || true
        ${hyprctl} --instance 0 'dispatch exec hyprlock'
      '';
    };

  flake.modules.homeManager.base =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      inherit (lib) getExe getExe';

      hyprctl = getExe' pkgs.hyprland "hyprctl";
      pidof = getExe' pkgs.procps "pidof";
      notify-send = getExe' pkgs.libnotify "notify-send";

      hyprlock = getExe self.packages.${system}.hyprlock;
      fork = getExe self.packages.${system}.fork;

      hyprland-exec = cmd: "${fork} ${pkgs.writeShellScript "hyprlock-script" cmd}";
    in
    {
      home.packages = [ self.packages.${system}.hyprlock-restore ];
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = hyprland-exec "${pidof} hyprlock || ${hyprlock}";
            before_sleep_cmd = hyprland-exec "loginctl lock-session";
            after_sleep_cmd = hyprland-exec "${hyprctl} dispatch dpms on";
          };
          listener = [
            {
              timeout = 295;
              on-timeout = hyprland-exec /* bash */ ''
                ${notify-send} 'Locking the session in 5 seconds'
              '';
            }
            {
              timeout = 300;
              on-timeout = hyprland-exec /* bash */ ''
                ${pidof} hyprlock || ${hyprlock}
              '';
            }
            {
              timeout = 360;
              on-timeout = "${hyprctl} dispatch dpms off";
              on-resume = "${hyprctl} dispatch dpms on";
            }
          ];
        };
      };
    };
}
