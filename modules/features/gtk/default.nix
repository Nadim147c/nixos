{ lib, ... }:
let
  inherit (lib) singleton genAttrs const;
  inherit (lib.x.generators) toGtkINI;
in
{
  flake.modules.nixos.gui = { config, pkgs, ... }: {
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

    hj.xdg.config.files =
      genAttrs [
        "gtk-3.0/settings.ini"
        "gtk-4.0/settings.ini"
      ]
      <| const {
        generator = toGtkINI;
        value.Settings = {
          theme-name = "Adwaita";
          icon-theme-name = "Adwaita";
          font-name = "${config.custom.font.sans} ${toString config.custom.font.size}";
          cursor-theme-name = config.cursor.name;
          cursor-theme-size = config.cursor.size;
          application-prefer-dark-theme = 1;
        };
      };

    packages = with pkgs; [
      adw-gtk3
      adwaita-icon-theme
    ];
    sessionVariables = {
      GTK_THEME = "adw-gtk3-dark";
      GTK_CSD = "0";
    };
  };
}
