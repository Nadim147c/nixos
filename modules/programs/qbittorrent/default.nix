{ lib, ... }:
let
  inherit (lib)
    toList
    collect
    escape
    getExe
    getExe'
    mapAttrsRecursive
    ;
  inherit (builtins) isAttrs isString;
  inherit (lib.strings) join;
  inherit (lib.generators) toINI mkKeyValueDefault mkValueStringDefault;
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
      profileDir = config.home.xdg.state.directory;
      configFile = pkgs.writeText "qBittorrent.conf" <| generateDeepINI settings;
      settings = {
        LegalNotice.Accepted = true;
        Preferences = {
          Downloads.SavePath = "${config.home.directory}/files/torrents";
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

      home.systemd.services.qbittorrent = {
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
        toList
        <| pkgs.makeDesktopItem {
          name = "qBittorrent Web UI";
          desktopName = "qbittorrent-nox";
          genericName = "Internet Manager";
          exec = "${getExe' pkgs.xdg-utils "xdg-open"} http://localhost:1616";
          terminal = false;
          categories = [ "Network" ];
          icon = "qbittorrent";
          type = "Application";
        };
    };
}
