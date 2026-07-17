{
  flake.modules.nixos.gui = { pkgs, ... }: {
    preserveHome.directories = [
      ".config/gtk-3.0"
      ".config/gtk-4.0"
      ".config/nwg-look"
    ];

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
