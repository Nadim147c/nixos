{
  config,
  lib,
  ...
}:
let
  inherit (config) username;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkForce;
in
{
  flake.tree.nixos.server.navidrome = { config, pkgs, ... }: {
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
          genericName = "Music Server";
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

    systemd.services.navidrome.serviceConfig.ProtectHome = mkForce false;
    services.navidrome = {
      enable = true;
      openFirewall = true;
      package = pkgs.navidrome.overrideAttrs (old: {
        patches = [ ./i-hate-album-artists.patch ];
        doCheck = false;
      });
      plugins = with pkgs.pkgsCross.wasi32.navidromePlugins; [
        lyrics-plugin
        apple-music
      ];
      user = username;
      environmentFile = config.sops.secrets.navidrome.path;
      settings = {
        MusicFolder = config.xdg-dirs.music;
        DataFolder = "/var/lib/navidrome";
        Port = 4533;
        Scanner.PurgeMissing = "always";
        EnableWebPEncoding = true;
        Agents = "apple-music,deezer,lastfm";
        Subsonic = {
          AppendAlbumVersion = false;
          AppendSubtitle = false;
          ArtistParticipations = true;
          DefaultReportRealPath = true;
        };
      };
    };
  };

}
