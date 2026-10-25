{ config, lib, ... }:
let
  inherit (lib.attrsets) isAttrs collect mapAttrsRecursive;
  inherit (lib.generators) toINI mkKeyValueDefault mkValueStringDefault;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe getExe';
  inherit (lib.strings) escape isString join;
  inherit (config.flake.tree) nixos;

  port = 1616;
in
{
  flake.tree.nixos.server.qbittorrent =
    { config, pkgs, ... }:
    let
      iniNameValueSep = "=";
      createINILine =
        key: path: val:
        let
          fullpath = join "\\" ([ key ] ++ path);
          name = escape [ iniNameValueSep ] fullpath;
          value = mkValueStringDefault { } val;
        in
        "${name}${iniNameValueSep}${value}";

      attrsToLines =
        key: attrs: mapAttrsRecursive (createINILine key) attrs |> collect isString |> join "\n";

      generateQBittorrentConfig = toINI {
        mkKeyValue =
          name: value:
          if isAttrs value then attrsToLines name value else mkKeyValueDefault { } iniNameValueSep name value;
      };

      profileDir = config.hj.xdg.state.directory;
      configFile = pkgs.writeText "qBittorrent.conf" <| generateQBittorrentConfig settings;
      settings = {
        LegalNotice.Accepted = true;
        Preferences = {
          Advanced.updateCheck = false;
          Search.SearchEnabled = true;
          Downloads.SavePath = "${config.hj.directory}/files/torrents";
          WebUI = {
            AlternativeUIEnabled = true;
            RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
            AuthSubnetWhitelist = "192.168.1.0/24";
            AuthSubnetWhitelistEnabled = true;
            LocalHostAuth = false;
          };
        };
      };

      nyaasi = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/f84b6cb5efe38f60f9d64c718392fd2ae41383a3/engines/nyaasi.py";
        hash = "sha256-izjet9IthsPWQwDNWNVYECYOphuWsP1VLDdIIB3kTkY=";
      };
    in
    {
      systemd.user.tmpfiles.rules = [
        "d ${profileDir}/qBittorrent 0700 - - -"
        "d ${profileDir}/qBittorrent/config 0700 - - -"
        "L+ ${profileDir}/qBittorrent/config/qBittorrent.conf - - - - ${configFile}"
        "L+ ${profileDir}/qBittorrent/data/nova3/engines/nyaasi.py - - - - ${nyaasi}"
      ];

      hj.systemd.services.qbittorrent = {
        enable = true;
        description = "qBittorrent user";
        after = singleton "network-online.target";
        wantedBy = singleton "default.target";
        reloadTriggers = [
          configFile
          nyaasi
        ];

        serviceConfig = {
          ExecStart = "${getExe pkgs.qbittorrent-nox} --profile=${profileDir} --webui-port=${toString port}";
          Restart = "on-failure";
          TimeoutStopSec = 1800;
        };
      };

    };

  flake.tree.nixos.gui.qbittorrent =
    { pkgs, ... }:
    {
      imports = [ nixos.server.qbittorrent ];
      packages = [
        (pkgs.makeIcons "qbittorrent" "${pkgs.vuetorrent}/share/vuetorrent/public/favicon.ico")
        (pkgs.makeDesktopItem {
          name = "qbittorrent-nox";
          desktopName = "qBittorrent Web UI";
          genericName = "Downloader";
          exec = "${getExe' pkgs.xdg-utils "xdg-open"} http://127.0.0.1:${toString port}";
          terminal = false;
          categories = [
            "Network"
            "X-Bittorrent"
          ];
          icon = "qbittorrent";
          type = "Application";
        })
      ];
    };
}
