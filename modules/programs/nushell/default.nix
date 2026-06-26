{ lib, ... }:
let
  inherit (lib.x) opt;
  inherit (lib.hm.nushell) toNushell;
  inherit (lib)
    mkIf
    mkMerge
    mkAliasOptionModule
    concatMapAttrsStringSep
    ;

in
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      inherit (config.environment) shellAliases;
      cfg = config.programs.nushell;

      makeSource = name: value: "source ${pkgs.mkInitScript "init-${name}.nu" value}";
      extraInit = concatMapAttrsStringSep "\n" makeSource cfg.init;
      alias = concatMapAttrsStringSep "\n" (name: value: "alias ${name} = ${value}") shellAliases;
    in
    {
      imports = [
        (mkAliasOptionModule
          [ "programs" "nushell" "interactiveShellInit" ]
          [ "programs" "nushell" "extraConfig" ]
        )
      ];
      options.programs.nushell = {
        enable = opt.bool true;
        package = opt.null.pkg pkgs.nushell;
        extraConfig = opt.block "";
        init = opt.attrs.block { };
        settings = opt.attrs.recursive {
          show_banner = false;
          edit_mode = "vi";
          cursor_shape = {
            vi_insert = "line";
            vi_normal = "block";
            emacs = "block";
          };
          history = {
            file_format = "sqlite";
            isolation = false;
            max_size = 5000000;
            sync_on_enter = true;
          };
        };
      };

      config = mkIf cfg.enable {
        packages = mkIf (cfg.package != null) [ cfg.package ];
        home.xdg.config.files."nushell/config.nu".text = mkMerge [
          (mkIf (cfg.settings != { }) "$env.config = ${toNushell { } cfg.settings}")
          (mkIf (shellAliases != { }) alias)
          (mkIf (cfg.init != { }) extraInit)
          cfg.extraConfig
        ];
      };
    };
}
