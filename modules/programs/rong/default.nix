{
  self,
  inputs,
  lib,
  ...
}:
{

  perSystem =
    { pkgs, ... }:
    {
      packages.rong-impure = inputs.wrappers.lib.wrapPackage (_: {
        inherit pkgs;
        package = pkgs.lib.flakePackage inputs.rong;
        runShell = [
          /* bash */ ''
            local_override="$HOME/.local/bin/rong"
            if [ -x "$local_override" ]; then
              exec -a "$0" "$local_override" "$@"
              exit
            fi
          ''
        ];
      });
    };

  flake.modules.homeManager.base = {
    imports = [ inputs.rong.homeModules.rong ];
  };

  flake.modules.homeManager.gui =
    {
      config,
      system,
      ...
    }:
    {
      xdg.configFile."gtk-4.0/gtk.css".enable = lib.mkForce false;

      programs.rong = {
        enable = true;
        package = self.packages.${system}.rong-impure;
        # wallpaper = ./../../../wallpaper.png;
        settings = {
          dark = true;
          preview-format = "jpg";
          base16 = {
            blend = 0.5;
            method = "dynamic";
          };
          material = {
            contrast = 0.0;
            platform = "phone";
            variant = "tonal_spot";
            version = "2025";
            custom = {
              blend = 0.5;
              colors = {
                purple = "#800080";
                orange = "#FFA500";
                green = "#00FF00";
                red = "#FF0000";
              };
            };
          };
          links =
            let
              mkPath = prefix: list: lib.toList list |> map (x: "${prefix}/${x}");
            in
            {
              "qtct.colors" = "${config.xdg.dataHome}/color-schemes/Rong.colors";
              "qtct.conf" = mkPath config.xdg.configHome [
                "qt5ct/colors/rong.conf"
                "qt6ct/colors/rong.conf"
              ];
              "gtk.css" = mkPath config.xdg.configHome [
                "gtk-3.0/gtk.css"
                "gtk-4.0/gtk.css"
              ];
            };
        };
      };
    };
}
