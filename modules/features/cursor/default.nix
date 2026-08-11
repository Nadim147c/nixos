{ self, lib, ... }:
let
  inherit (lib.fixedPoints) fix;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.strings) escapeShellArg;
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
        packages = mkIf (cfg.package != null) <| singleton cfg.package;
        sessionVariables = {
          XCURSOR_SIZE = cfg.size;
          XCURSOR_THEME = cfg.name;
          HYPRCURSOR_SIZE = cfg.size;
          HYPRCURSOR_THEME = cfg.name;
        };

        hj.systemd.services.hyprland-set-cursor = fix (final: {
          enable = config.programs.hyprland.enable;
          description = "Hyprland set cursor";
          partOf = singleton "graphical-session.target";
          after = final.partOf;
          wantedBy = final.partOf;
          serviceConfig = {
            Type = "oneshot";
            ExecStart =
              let
                hyprctl = getExe' self.packages.${system}.hyprland "hyprctl";
              in
              "${hyprctl} setcursor ${escapeShellArg cfg.name} ${toString cfg.size}";
          };
        });
      };
    };
}
