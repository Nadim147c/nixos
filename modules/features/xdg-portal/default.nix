{
  flake.modules.nixos.base = {
    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };

  flake.modules.homeManager.gui =
    { pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.kdePackages.xdg-desktop-portal-kde
          pkgs.xdg-desktop-portal-hyprland
        ];
        config.common = {
          "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
          default = [
            "hyprland"
            "kde"
          ];
        };
      };

    };
}
