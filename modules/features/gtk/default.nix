{
  flake.modules.nixos.gui = { pkgs, ... }: {
    preserveHome.directories = [
      ".config/gtk-3.0"
      ".config/gtk-4.0"
      ".config/nwg-look"
    ];

    packages = with pkgs; [
      adw-gtk3
      adwaita-icon-theme
      nwg-look
    ];
    sessionVariables = {
      GTK_THEME = "adw-gtk3-dark";
    };
  };
}
