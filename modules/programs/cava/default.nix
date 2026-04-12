{ lib, ... }:
{
  flake.modules.homeManager.gui =
    { config, pkgs, ... }:
    {
      programs.rong.settings.themes = lib.toList {
        target = "cava.ini";
        links = "${config.xdg.configHome}/cava/themes/rong";
        cmds = "${lib.getExe' pkgs.procps "pkill"} -SIGUSR2 cava";
      };

      programs.cava = {
        enable = true;
        settings = {
          color.theme = "rong";
        };
      };
    };
}
