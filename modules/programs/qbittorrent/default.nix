{ lib, ... }:
let
  inherit (lib.attrsets) isAttrs collect mapAttrsRecursive;
  inherit (lib.generators) toINI mkKeyValueDefault mkValueStringDefault;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe getExe';
  inherit (lib.strings) escape isString join;
in
{
  flake.modules.nixos.base =
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

      generateDeepINI = toINI {
        mkKeyValue =
          name: value:
          if isAttrs value then attrsToLines name value else mkKeyValueDefault { } iniNameValueSep name value;
      };

      port = 1616;
      profileDir = config.hj.xdg.state.directory;
      configFile = pkgs.writeText "qBittorrent.conf" <| generateDeepINI settings;
      settings = {
        LegalNotice.Accepted = true;
        Preferences = {
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
    in
    {
      systemd.user.tmpfiles.rules = [
        "d ${profileDir}/qBittorrent 0700 - - -"
        "d ${profileDir}/qBittorrent/config 0700 - - -"
        "L+ ${profileDir}/qBittorrent/config/qBittorrent.conf - - - - ${configFile}"
      ];

      hj.systemd.services.qbittorrent = {
        enable = true;
        description = "qBittorrent user";
        after = [ "network-online.target" ];
        wantedBy = [ "default.target" ];

        serviceConfig = {
          ExecStart = "${getExe pkgs.qbittorrent-nox} --profile=${profileDir} --webui-port=${toString port}";
          Restart = "on-failure";
          TimeoutStopSec = 1800;
        };
      };

    };

  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      packages =
        singleton
        <| pkgs.makeDesktopItem {
          name = "qbittorrent-nox";
          desktopName = "qBittorrent Web UI";
          genericName = "Internet Manager";
          exec = "${getExe' pkgs.xdg-utils "xdg-open"} http://localhost:1616";
          terminal = false;
          categories = [ "Network" ];
          icon = "qbittorrent";
          type = "Application";
        };
    };
}
