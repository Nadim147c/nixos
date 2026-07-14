{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib.x) singleton;
  inherit (lib) toList makeBinPath;
in
{

  perSystem = { pkgs, ... }: {
    packages.rong-impure = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.lib.flakePackage inputs.rong;
      prefixVar = singleton [
        "PATH"
        ":"
        (makeBinPath [ pkgs.ffmpeg ])
      ];
      runShell = singleton /* bash */ ''
        override="$HOME/.local/bin/rong"
        if [[ -x "$override" ]]; then
          exec -a "$0" "$override" "$@"
          exit
        fi
      '';
    };
  };

  flake.modules.nixos.base =
    {
      config,
      system,
      lib,
      ...
    }:
    let
      inherit (lib) mkIf;
      inherit (lib.options) mkOption mkEnableOption;
      inherit (lib.types)
        attrsOf
        bool
        float
        int
        listOf
        nullOr
        oneOf
        path
        str
        package
        ;

      cfg = config.programs.rong;
    in
    {
      options.programs.rong = {
        enable = mkEnableOption "rong";
        package = mkOption {
          type = nullOr package;
          default = self.packages.${system}.rong-impure;
        };
        settings = mkOption {
          type =
            let
              valueType = nullOr (oneOf [
                bool
                int
                float
                str
                path
                (attrsOf valueType)
                (listOf valueType)
              ]);
            in
            valueType;
          default = { };
        };
      };

      config = mkIf cfg.enable {
        packages = mkIf (cfg.package != null) [ cfg.package ];
        home.xdg.config.files."rong/config.json" = mkIf (cfg.settings != { }) {
          generator = builtins.toJSON;
          value = cfg.settings;
        };
      };
    };

  flake.modules.nixos.gui =
    {
      config,
      system,
      ...
    }:
    {
      programs.rong = {
        enable = true;
        package = self.packages.${system}.rong-impure;
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
            auto-monochrome = true;
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
              createPath = prefix: list: toList list |> map (x: "${prefix}/${x}");
            in
            {
              "qtct.colors" = "${config.home.xdg.data.directory}/color-schemes/Rong.colors";
              "qtct.conf" = createPath config.home.xdg.config.directory [
                "qt5ct/colors/rong.conf"
                "qt6ct/colors/rong.conf"
              ];
              "gtk.css" = createPath config.home.xdg.config.directory [
                "gtk-3.0/gtk.css"
                "gtk-4.0/gtk.css"
              ];
            };
        };
      };

    };
}
