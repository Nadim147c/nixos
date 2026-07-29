{ config, lib, ... }:
let
  inherit (config) username;
  inherit (lib)
    genAttrs
    const
    singleton
    mkForce
    ;
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
}
