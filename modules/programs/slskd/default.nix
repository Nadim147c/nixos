{ config, lib, ... }:
let
  inherit (config) username;
  inherit (lib.meta) getExe';
  inherit (lib.lists) singleton;
  inherit (lib.modules) mkForce;
  inherit (builtins) attrValues;
in
{
  flake.tree.nixos.server.slskd =
    {
      config,
      pkgs,
      ...
    }:
    {
      systemd.services.slskd.serviceConfig = {
        ProtectHome = mkForce "tmpfs";
        BindPaths = singleton config.xdg-dirs.torrents; # read-write
        BindReadOnlyPaths = singleton config.xdg-dirs.music; # read-only
      };
      services.slskd = {
        enable = true;
        openFirewall = true;
        environmentFile = config.sops.secrets.slskd.path;
        user = username;
        settings = {
          directories = {
            downloads = "${config.xdg-dirs.torrents}/downloads";
            incomplete = "${config.xdg-dirs.torrents}/slskd-incomplete";
          };
          shares.directories = singleton config.xdg-dirs.music;
        };
      };

      systemd.tmpfiles.rules =
        attrValues config.services.slskd.settings.directories
        |> map (dir: "d ${dir} 0755 ${username} users - -");

      packages = [
        (pkgs.makeIcons "slskd" "${pkgs.slskd}/lib/slskd/wwwroot/favicon.ico")
        (pkgs.makeDesktopItem {
          name = "slskd";
          desktopName = "Soulseek";
          genericName = "Downloader";
          comment = "Soulseek daemon web interface";
          exec = "${getExe' pkgs.xdg-utils "xdg-open"} http://127.0.0.1:${toString config.services.slskd.settings.web.port}";
          terminal = false;
          categories = [
            "Network"
            "FileTransfer"
            "P2P"
          ];
          icon = "slskd";
          type = "Application";
        })
      ];
    };
}
