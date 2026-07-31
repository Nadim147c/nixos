{ lib, ... }:
let
  inherit (lib)
    fix
    getExe
    getExe'
    singleton
    ;
in
{

  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    let
      scss = "${config.hj.xdg.config.directory}/swaync/style.scss";
      css = "${config.hj.xdg.config.directory}/swaync/style.css";
    in
    {
      packages = with pkgs; [
        swaynotificationcenter
        libnotify
      ];

      hj.systemd.services.swaync = fix (final: {
        enable = true;
        description = "sway notifcation center daemon";
        partOf = singleton "graphical-session.target";
        after = final.partOf;
        wantedBy = final.partOf;
        unitConfig = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        serviceConfig = {
          ExecStart = getExe' pkgs.swaynotificationcenter "swaync";
        };
      });

      hj.xdg.config.files."swaync/style.scss".source = ./swaync.scss;

      programs.rong.settings.themes = singleton {
        target = "colors.scss";
        links = "${config.hj.xdg.config.directory}/swaync/colors.scss";
        cmds = /* bash */ ''
          ${getExe pkgs.dart-sass} --no-source-map "${scss}:${css}"
          ${getExe' pkgs.systemd "systemctl"} --user restart swaync.service
        '';
      };
    };
}
