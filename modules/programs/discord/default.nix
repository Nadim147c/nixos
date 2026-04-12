{ lib, ... }:
{

  flake.modules.homeManager.gui =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.equibop ];

      programs.rong.settings.links."midnight-discord.css" = [
        "${config.xdg.configHome}/equibop/settings/quickCss.css"
      ];

      xdg.mimeApps = lib.x.genMimes "equibop.desktop" [ "x-scheme-handler/discord" ];
    };
}
