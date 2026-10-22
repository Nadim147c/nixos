{ config, ... }:
let
  inherit (builtins) attrValues;
  inherit (config.flake.tree.nixos)
    base
    dev
    gui
    hack
    network
    wireless
    game
    server
    ;
in
{
  configurations.nixos.chronoshift.module =
    { pkgs, ... }:
    {
      imports = [
        { }
      ]
      ++ attrValues dev
      ++ attrValues gui
      ++ attrValues hack
      ++ attrValues network
      ++ attrValues wireless
      ++ attrValues game
      ++ attrValues server
      ++ attrValues base;

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

      security.pki.caCertificateBlacklist = [
        # CVE-2026-111943
        "Comodo AAA Services root"
        # https://hg-edge.mozilla.org/projects/nss/rev/26d38a0c3fb81e7fb2acedbaf4c42dd21dce0517
        "emSign ECC Root CA - G3"
        # https://hg-edge.mozilla.org/projects/nss/rev/8159223c48ceeb1273a1915bca95a517294ab0e0
        "emSign Root CA - C1"
        "emSign ECC Root CA - C3"
      ];
      systemd.services.ModemManager.enable = false;

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
