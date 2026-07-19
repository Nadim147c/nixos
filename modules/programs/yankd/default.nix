{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) fix getExe singleton;
in
{
  perSystem = { pkgs, ... }: {
    packages.yankd-impure = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.lib.flakePackage inputs.yankd;
      runShell = singleton /* bash */ ''
        override="$HOME/.local/bin/yankd"
        if [ -x "$override" ]; then
          exec -a "$0" "$override" "$@"
          exit
        fi
      '';
    };
  };

  flake.modules.nixos.gui = { system, ... }: {
    packages = singleton self.packages.${system}.yankd-impure;

    preserveHome.directories = singleton ".local/share/yankd";

    home.systemd.services.yankd = fix (final: {
      enable = true;
      description = "yankd wayland clipboard daemon";
      partOf = singleton "graphical-session.target";
      after = final.partOf;
      wantedBy = final.partOf;
      serviceConfig = {
        ExecStart = "${getExe self.packages.${system}.yankd-impure} daemon";
      };
    });
  };
}
