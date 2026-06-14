{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) getExe toList;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.yankd-impure = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.lib.flakePackage inputs.yankd;
        runShell = toList /* bash */ ''
          override="$HOME/.local/bin/yankd"
          if [ -x "$override" ]; then
            exec -a "$0" "$override" "$@"
            exit
          fi
        '';
      };
    };

  flake.modules.nixos.gui =
    { system, ... }:
    {
      packages = toList self.packages.${system}.yankd-impure;
      home.systemd.services.yankd = rec {
        enable = true;
        description = "yankd wayland clipboard daemon";
        partOf = toList "graphical-session.target";
        after = partOf;
        wantedBy = partOf;
        serviceConfig = {
          ExecStart = "${getExe self.packages.${system}.yankd-impure} daemon";
        };
      };
    };
}
