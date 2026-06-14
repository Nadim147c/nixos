{ lib, ... }:
{

  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    {
      packages = [ pkgs.equibop ];

      programs.rong.settings.links."midnight-discord.css" = [
        "${config.home.xdg.config.directory}/equibop/settings/quickCss.css"
      ];

      home.xdg.mime-apps = lib.x.genMimes "equibop.desktop" [ "x-scheme-handler/discord" ];
    };
}
