{ config, lib, ... }:
let
  inherit (lib.x) generateConfig;
  inherit (config.flake.tree) nixos;
in
{
  configurations.nixos.chronoshift.module =
    { pkgs, ... }:
    {
      imports = generateConfig nixos {
        gui.ghostty = false;
        game.steam = false;
      };

      cursor.size = 24;

      displays = {
        "eDP-1".enable = false;
        "DP-1" = {
          enable = true;
          primary = true;
          refreshRate = 60.00;
          width = 1920;
          height = 1080;
          x = 0;
          y = 0;
        };
      };

      systemd.services.ModemManager.enable = false;

      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "chronoshift";
      system.stateVersion = "26.05";

      hardware.graphics = {
        extraPackages = with pkgs; [
          intel-media-driver
          libvdpau-va-gl
          ffmpeg
        ];
      };

      environment.systemPackages = with pkgs; [
        libva
        libva-utils
      ];

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
        QT_MEDIA_BACKEND = "ffmpeg";
      };
    };
}
