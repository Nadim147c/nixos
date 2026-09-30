{
  config,
  self,
  lib,
  ...
}:
let
  inherit (config) username;
  inherit (config.flake.modules) nixos;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkForce;
  inherit (lib.strings) escapeShellArg;

  appId = "io.github.nolight132.sonora";
  url = "https://github.com/sonorahq/sonora/releases/download/v0.42.0/sonora-v0.42.0-x86_64.flatpak";
  sha256 = "sha256-Vl4NKLv94ttp5YrFSrAo7tBt77ehIZMUuQDhO7UkTwg=";
in
{
  flake.modules.nixos.gui = { config, pkgs, ... }: {
    imports = [ nixos.navidrome ];
    packages =
      singleton
      <| pkgs.makeDesktopItem {
        name = "navidrome";
        desktopName = "Navidrome";
        genericName = "Media Server";
        comment = "Navidrome Media Server";
        exec = "${getExe' pkgs.xdg-utils "xdg-open"} http://127.0.0.1:${toString config.services.navidrome.settings.Port}";
        terminal = false;
        categories = [
          "AudioVideo"
          "Audio"
          "Player"
        ];
        icon = "navidrome";
        type = "Application";
      };
  };

  flake.modules.nixos.navidrome =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      preserve.directories = singleton "/var/lib/navidrome";

      hj.programs.hyprland = {
        windowRules = singleton {
          name = "music player workspace 4";
          match.class = "^(sonora)$";
          workspace = "4 silent";
        };
        programs = singleton {
          keys = [
            "SUPER"
            "M"
          ];
          autostart = true;
          exec = "${getExe self.packages.${system}.control} flatpak run -- ${escapeShellArg appId}";
        };
      };
      services.flatpak = {
        packages = singleton {
          inherit sha256 appId;
          bundle = toString <| pkgs.fetchurl { inherit sha256 url; };
        };
        overrides."${appId}" = {
          Context.filesystems = [ "xdg-music" ];
        };
      };

      systemd.services.navidrome.serviceConfig.ProtectHome = mkForce false;
      services.navidrome = {
        enable = true;
        openFirewall = true;
        user = username;
        # environmentFile = config.sops.secrets.navidrome.path;
        settings = {
          MusicFolder = config.xdg-dirs.music;
          DataFolder = "/var/lib/navidrome";
          Port = 4533;
        };
      };

    };
}
