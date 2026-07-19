{ lib, ... }:
let
  inherit (lib) fix getExe' singleton;
in
{
  flake.modules.nixos.gui = { pkgs, ... }: {
    programs.kdeconnect.enable = true;

    home.systemd.services.kdeconnect-indicator = fix (final: {
      enable = true;
      description = "Kdeconnect Indicator";
      requires = singleton "tray.target";
      partOf = singleton "graphical-session.target";
      after = [
        "graphical-session.target"
        "tray.target"
      ];
      wantedBy = singleton "graphical-session.target";
      serviceConfig = {
        ExecStart = getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-indicator";
      };
    });
  };
}
