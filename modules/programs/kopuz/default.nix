{
  self,
  lib,
  ...
}:
let
  inherit (lib) toList escapeShellArg;
  appId = "com.temidaradev.kopuz";
  sha256 = "sha256-Xbwb8Cpa2dUsR0viPHxz870H+ENfscevFTd8zkcTHFc=";
  url = "https://github.com/Kopuz-org/kopuz/releases/download/v0.7.0/kopuz.flatpak";
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.kopuz = pkgs.writeShellScriptBin "kopuz" /* bash */ ''
        exec -a "kopuz" flatpak run -- ${escapeShellArg appId} "$@"
      '';
    };
  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      services.flatpak = {
        packages = toList {
          inherit sha256 appId;
          bundle = toString <| pkgs.fetchurl { inherit sha256 url; };
        };
        overrides.settings."${appId}" = {
          Context.filesystems = [
            "xdg-config/kopuz"
            "xdg-music"
            "xdg-run/app/${config.programs.discord.appId}"
          ];
        };
      };
      packages = [
        self.packages.${system}.kopuz
        pkgs.picard
        pkgs.nicotine-plus
        pkgs.lrcget
      ];
    };
}
