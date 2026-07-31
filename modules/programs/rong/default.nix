{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    getExe
    makeBinPath
    singleton
    ;
in
{

  perSystem = { pkgs, ... }: {
    packages.rong-impure = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.lib.flakePackage inputs.rong;
      prefixVar =
        let
          runtimeInputs = with pkgs; [
            ffmpeg
            bash
          ];
        in
        singleton [
          "PATH"
          ":"
          (makeBinPath runtimeInputs)
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
        hj.xdg.config.files."rong/config.json" = mkIf (cfg.settings != { }) {
          generator = builtins.toJSON;
          value = cfg.settings;
        };
      };
    };

  flake.modules.nixos.gui =
    { system, ... }:
    {
      preserveHome.directories = singleton ".local/state/rong";

      hj.systemd.services.rong-generate = {
        enable = true;
        description = "Generate rong colors";
        before = singleton "graphical-session.target";
        wantedBy = singleton "graphical-session-pre.target";
        serviceConfig = {
          ExecStart = "-${getExe self.packages.${system}.rong-impure} regen";
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
      };

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
            variant = "content";
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
        };
      };
    };
}
