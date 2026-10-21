{
  config,
  self,
  lib,
  ...
}:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (lib.strings) escapeShellArg;
  inherit (config.flake.flatpak.apps.sonora) url sha256;

  appId = "io.github.nolight132.sonora";
in
{
  flake.modules.nixos.gui =
    { system, pkgs, ... }:
    {
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
          inherit appId sha256;
          bundle = toString <| pkgs.fetchurl { inherit url sha256; };
        };
        overrides.settings."${appId}" = {
          Context.filesystems = [
            "xdg-config/sonora"
            "xdg-music"
          ];
        };
      };
    };
}
