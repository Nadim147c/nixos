{ lib, ... }:
let
  inherit (lib) toList getExe getExe';
in
{

  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    let
      scss = "${config.home.xdg.config.directory}/swaync/style.scss";
      css = "${config.home.xdg.config.directory}/swaync/style.css";
    in
    {
      packages = [
        pkgs.swaynotificationcenter
        pkgs.libnotify
      ];

      home.systemd.services.swaync = rec {
        enable = true;
        description = "sway notifcation center daemon";
        partOf = toList "graphical-session.target";
        after = partOf;
        wantedBy = partOf;
        unitConfig = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        serviceConfig = {
          ExecStart = getExe' pkgs.swaynotificationcenter "swaync";
        };
      };

      home.xdg.config.files."swaync/style.scss".source = ./swaync.scss;

      programs.rong.settings.themes = toList {
        target = "colors.scss";
        links = "${config.home.xdg.config.directory}/swaync/colors.scss";
        cmds = /* bash */ ''
          ${getExe pkgs.dart-sass} --no-source-map "${scss}:${css}"
          systemctl --user restart swaync.service
        '';
      };
    };
}
