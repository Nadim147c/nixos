{ lib, ... }:
let
  inherit (lib.fixedPoints) fix;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe';
in
{
  flake.modules.nixos.gui = { pkgs, ... }: {
    preserveHome.directories = singleton ".config/kdeconnect";

    programs.kdeconnect.enable = true;

    hj.systemd.services.kdeconnect-indicator = fix (final: {
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
