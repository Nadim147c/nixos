{ lib, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = with pkgs.kdePackages; [
        dolphin
        ffmpegthumbs
        kdegraphics-thumbnailers
        qtsvg
      ];

      wayland.windowManager.hyprland.settings = {
        "$files" = lib.x.wrapUWSM' pkgs pkgs.kdePackages.dolphin "dolphin";
      };

      xdg.configFile."dolphinrc".text = ''
        [UiSettings]
        ColorScheme=Rong
      '';
    };
}
