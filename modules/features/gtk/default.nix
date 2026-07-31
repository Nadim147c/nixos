{ lib, ... }:
let
  inherit (lib) singleton;
in
{
  flake.modules.nixos.gui = { config, pkgs, ... }: {
    preserveHome.directories = [
      ".config/gtk-3.0"
      ".config/gtk-4.0"
      ".config/nwg-look"
    ];

    programs.rong.settings.themes = singleton {
      target = "gtk.css";
      links = [
        "${config.hj.xdg.config.directory}/gtk-3.0/gtk.css"
        "${config.hj.xdg.config.directory}/gtk-4.0/gtk.css"
      ];
      cmds = pkgs.writers.writeNu "reload-gtk" /* nu */ ''
        $env.PATH = $env.PATH | append "${pkgs.glib.bin}/bin"
        let current = gsettings get org.gnome.desktop.interface color-scheme | str trim

        if $current == "prefer-dark" {
          gsettings set org.gnome.desktop.interface color-scheme prefer-light
          gsettings set org.gnome.desktop.interface color-scheme prefer-dark
        } else {
          gsettings set org.gnome.desktop.interface color-scheme prefer-dark
          gsettings set org.gnome.desktop.interface color-scheme prefer-light
        }
      '';
    };

    packages = with pkgs; [
      adw-gtk3
      adwaita-icon-theme
      nwg-look
    ];
    sessionVariables = {
      GTK_THEME = "adw-gtk3-dark";
      GTK_CSD = "0";
    };
  };
}
