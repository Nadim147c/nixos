{
  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      packages = [
        pkgs.adw-gtk3
        pkgs.adwaita-icon-theme
        pkgs.nwg-look
      ];
      sessionVariables = {
        GTK_THEME = "adw-gtk3-dark";
      };
    };
}
