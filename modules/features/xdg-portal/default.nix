{
  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = false;
        extraPortals = [
          pkgs.kdePackages.xdg-desktop-portal-kde
          pkgs.xdg-desktop-portal-gtk
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
