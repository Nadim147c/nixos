{ self, lib, ... }:
let
  inherit (lib)
    escapeShellArg
    getExe'
    mkIf
    toList
    ;
  inherit (lib.x) opt;
in
{
  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      cfg = config.cursor;
    in
    {
      options.cursor = {
        enable = opt.bool true;
        package = opt.pkg pkgs.bibata-cursors;
        name = opt.line "Bibata-Modern-Classic";
        size = opt.int 32;
      };

      config = mkIf cfg.enable {
        packages = mkIf (cfg.package != null) [ cfg.package ];
        sessionVariables = {
          XCURSOR_SIZE = cfg.size;
          XCURSOR_THEME = cfg.name;
          HYPRCURSOR_SIZE = cfg.size;
          HYPRCURSOR_THEME = cfg.name;
        };

        home.systemd.services.hyprland-set-cursor = mkIf config.programs.hyprland.enable rec {
          enable = true;
          description = "Hyprland set cursor";
          partOf = toList "graphical-session.target";
          after = partOf;
          wantedBy = partOf;
          serviceConfig = {
            Type = "oneshot";
            ExecStart =
              let
                hyprctl = getExe' self.packages.${system}.hyprland "hyprctl";
              in
              "${hyprctl} setcursor ${escapeShellArg cfg.name} ${toString cfg.size}";
          };
        };
      };
    };
}
