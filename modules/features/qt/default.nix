{
  flake.modules.nixos.gui = { pkgs, ... }: {
    preserveHome.directories = [
      ".config/qt5ct"
      ".config/qt6ct"
    ];

    sessionVariables = {
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };
    packages = with pkgs; [
      libsForQt5.qt5ct
      qt6Packages.qt6ct
      kdePackages.breeze-icons
    ];
  };
}
