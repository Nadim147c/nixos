{
  flake.modules.homeManager.gui =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      createFont =
        name:
        let
          fontName = config.custom.font."${name}";
          size = toString config.custom.font.size;
        in
        "${fontName} ${size}";
    in
    {
      gtk = {
        enable = false;
        iconTheme = {
          name = "Adwaita-dark";
          package = pkgs.adwaita-icon-theme;
        };

        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };

        font = lib.mkIf config.custom.font.enable {
          name = config.custom.font.sans;
          size = config.custom.font.size;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      # dconf.settings."org/gnome/desktop/interface" = {
      #   icon-theme = "Adwaita-dark";
      #   gtk-theme = "adw-gtk3-dark";
      #   color-scheme = "prefer-dark";
      #   font-antialiasing = "rgba";
      #   font-hinting = "full";
      #   font-name = createFont "sans";
      #   document-font-name = createFont "sans";
      #   monospace-font-name = createFont "mono";
      # };
    };
}
