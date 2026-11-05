{ config, lib, ... }:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkForce;
  inherit (config) username;
in
{
  flake.tree.nixos.server.qbittorrent =
    { config, pkgs, ... }:
    {
      packages = [
        (pkgs.makeIcons "qbittorrent" "${pkgs.vuetorrent}/share/vuetorrent/public/favicon.ico")
        (pkgs.makeDesktopItem {
          name = "qbittorrent-nox";
          desktopName = "qBittorrent";
          genericName = "Downloader";
          exec = "${getExe' pkgs.xdg-utils "xdg-open"} http://127.0.0.1:${toString config.services.qbittorrent.webuiPort}";
          terminal = false;
          categories = [
            "Network"
            "X-Bittorrent"
          ];
          icon = "qbittorrent";
          type = "Application";
        })
      ];

      systemd.services.qbittorrent.serviceConfig = {
        ProtectHome = mkForce "tmpfs";
        BindPaths = singleton config.xdg-dirs.torrents; # read-write
      };

      systemd.tmpfiles.rules =
        [
          "qbittorrent-incomplete"
          "torrent-files"
          "downloads"
        ]
        |> map (dir: "d ${config.xdg-dirs.torrents}/${dir} 0755 ${username} users - -");

      services.qbittorrent = {
        enable = true;
        openFirewall = true;
        webuiPort = 1616;
        user = username;
        serverConfig = {
          LegalNotice.Accepted = true;
          BitTorrent.Session = {
            TempPathEnabled = true;
            TempPath = "${config.xdg-dirs.torrents}/qbittorrent-incomplete";
            TorrentExportDirectory = "${config.xdg-dirs.torrents}/torrent-files";
          };
          Preferences = {
            Advanced.updateCheck = false;
            Search.SearchEnabled = true;
            Downloads.SavePath = "${config.xdg-dirs.torrents}/downloads";
            WebUI = {
              AlternativeUIEnabled = true;
              RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
              AuthSubnetWhitelist = "192.168.1.0/24";
              AuthSubnetWhitelistEnabled = true;
              LocalHostAuth = false;
            };
          };
        };
      };
    };
}
