{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  configurations.nixos.chronoshift.module =
    { pkgs, ... }:
    {
      imports = [
        nixos.base
        nixos.dev
        nixos.gui
        nixos.hack
        nixos.pc
        nixos.wireless
      ];

      # Small ahh display
      custom.cursor.size = 22;

      displays = {
        "eDP-1".enable = false;
        "DP-1" = {
          enable = true;
          primary = true;
          refreshRate = 59.79;
          width = 1366;
          height = 768;
          x = 0;
          y = 0;
        };
      };

      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "chronoshift";
      system.stateVersion = "25.11";

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
