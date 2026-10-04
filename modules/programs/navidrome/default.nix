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
in
{
  flake.modules.nixos.gui = { config, pkgs, ... }: {
    imports = [ nixos.navidrome ];
    packages =
      let
        ico = pkgs.fetchurl {
          url = "https://github.com/navidrome/navidrome/raw/0e1893530b844898cbf87825fdefd4b13e1ff3cc/ui/public/favicon.ico";
          hash = "sha256-RVrsX6Qj5RYM4/eOPx1B7VIXrxFOqyLRaEJlZUJoWrk=";
        };
      in
      [
        (pkgs.makeIcons "navidrome" ico)
        (pkgs.makeDesktopItem {
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
        })
      ];
  };

  flake.modules.nixos.navidrome =
    {
      config,
      system,
      ...
    }:
    {
      preserve.directories = singleton "/var/lib/navidrome";
      preserveHome.directories = singleton ".config/sonora";

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

      hj.xdg.config.files."rong/templates/sonora.json.tmpl".source = ./sonora-theme.json;

      programs.rong.settings.themes = singleton {
        target = "sonora.json";
        links = "~/.config/sonora/themes/rong.json";
      };

      services.flatpak = {
        packages = singleton {
          flatpakref = "https://sonorahq.github.io/sonora/sonora.flatpakref";
          sha256 = "sha256-nlOzictk6E3Ikt2XVn/twG9JVrFb3Vm5tAyVlHz1CP4=";
        };
        overrides."${appId}" = {
          Context.filesystems = [
            "xdg-config/sonora"
            "xdg-music"
          ];
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
          Scanner.PurgeMissing = "always";
        };
      };

    };
}
