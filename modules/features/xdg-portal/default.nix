{ lib, ... }:
let
  inherit (lib) attrValues;
in
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
        extraPortals = attrValues {
          inherit (pkgs.kdePackages) xdg-desktop-portal-kde;
          inherit (pkgs) xdg-desktop-portal-gtk xdg-desktop-portal-gnome;
        };
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
