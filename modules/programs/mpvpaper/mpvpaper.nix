{ self, lib, ... }:
let
  inherit (lib) getExe toList;
in
{

  flake.modules.nixos.gui =
    {
      pkgs,
      system,
      ...
    }:
    {
      packages = with pkgs; [ mpvpaper ];

      home.systemd.services.mpvpaper-daemon = rec {
        enable = true;
        description = "mpvpaper control daemon";
        partOf = toList "graphical-session.target";
        after = partOf;
        wantedBy = partOf;
        serviceConfig = {
          ExecStart = getExe self.packages.${system}.mpvpaper-daemon;
          RestartSec = 10;
        };
      };
    };
}
