{ config, lib, ... }:
let
  inherit (config) username;
  inherit (lib.meta) getExe';
  inherit (lib.attrsets) genAttrs;
  inherit (lib.lists) singleton;
  inherit (lib.modules) mkForce;
  inherit (lib.trivial) const;
in
{
  flake.modules.nixos.base = { config, ... }: {
    preserve.directories = singleton "/var/lib/slskd";

    systemd.services.slskd.serviceConfig.ProtectHome = mkForce false;

    services.slskd = {
      enable = true;
      openFirewall = true;
      environmentFile = config.sops.secrets.slskd.path;
      user = username;
      settings = {
        directories = genAttrs [ "incomplete" "downloads" ] (const config.xdg-dirs.torrents);
        shares.directories = singleton config.xdg-dirs.music;
      };
    };
  };

  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    {
      packages =
        singleton
        <| pkgs.makeDesktopItem {
          name = "slskd";
          desktopName = "Soulseek Client";
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
        };
    };
}
