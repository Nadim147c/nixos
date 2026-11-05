{
  inputs,
  lib,
  ...
}:
let
  inherit (lib.fixedPoints) fix;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
in
{
  perSystem = { pkgs, inputs', ... }: {
    packages.yankd-impure = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = inputs'.yankd.packages.yankd;
      runShell = singleton /* bash */ ''
        override="$HOME/.local/bin/yankd"
        if [ -x "$override" ]; then
          exec -a "$0" "$override" "$@"
          exit
        fi
      '';
    };
  };

  flake.tree.nixos.gui.yankd = { self', ... }: {
    packages = singleton self'.packages.yankd-impure;

    hj.systemd.services.yankd = fix (final: {
      enable = true;
      description = "yankd wayland clipboard daemon";
      partOf = singleton "graphical-session.target";
      after = final.partOf;
      wantedBy = final.partOf;
      serviceConfig = {
        ExecStart = "${getExe self'.packages.yankd-impure} daemon";
      };
    });
  };
}
