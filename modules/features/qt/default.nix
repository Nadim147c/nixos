{ lib, ... }:
let
  inherit (lib.attrsets) attrValues;
  inherit (lib.meta) getExe';
in
{
  flake.modules.nixos.gui = { config, pkgs, ... }: {
    preserveHome.directories = [
      ".config/qt5ct"
      ".config/qt6ct"
    ];

    programs.rong.settings.themes = [
      {
        target = "qt6ct.conf";
        links = [
          "${config.hj.xdg.config.directory}/qt5ct/colors/rong.conf"
          "${config.hj.xdg.config.directory}/qt6ct/colors/rong.conf"
        ];
        cmds = ''
          ${getExe' pkgs.coreutils "touch"} ~/.config/qt5ct/qt5ct.conf ~/.config/qt6ct/qt6ct.conf
        '';
      }
      {
        target = "qtct.colors";
        links = "${config.hj.xdg.data.directory}/color-schemes/Rong.colors";
        cmds = ''
          ${getExe' pkgs.coreutils "touch"} ~/.config/dolphinrc
        '';
      }
    ];

    sessionVariables = {
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };

    packages = attrValues {
      inherit (pkgs.libsForQt5) qt5ct;
      inherit (pkgs.qt6Packages) qt6ct;
      inherit (pkgs.kdePackages) breeze-icons;
    };
  };
}
