{
  config,
  lib,
  ...
}:
let
  inherit (lib) getExe' getExe;
  inherit (config) username;
in
{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    let
      hyprland = getExe' pkgs.hyprland "start-hyprland";
      session = {
        user = username;
        command = "${getExe pkgs.uwsm} start ${hyprland}";
      };
    in
    {
      services.greetd = {
        enable = true;
        # do not restart on session exit (useful on autologin)
        restart = false;
        settings = {
          terminal.vt = 1;
          default_session = session;
          initial_session = session;
        };
      };
    };
}
