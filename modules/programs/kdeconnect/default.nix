{ lib, ... }:
let
  inherit (lib) toList getExe';
in
{
  flake.modules.nixos.pc = { pkgs, ... }: {
    programs.kdeconnect.enable = true;

    home.systemd.services.kdeconnect = rec {
      enable = true;
      description = "Kdeconnect Indicator";
      requires = toList "tray.target";
      partOf = toList "graphical-session.target";
      after = [
        "graphical-session.target"
        "tray.target"
      ];
      wantedBy = partOf;
      serviceConfig = {
        ExecStart = getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-indicator";
      };
    };
  };
}
