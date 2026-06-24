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
  perSystem = { pkgs, system, ... }: {
    packages.yankd-impure = pkgs.impurify inputs.yankd.packages.${system}.default;
  };

  flake.modules.nixos.gui = { system, ... }: {
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
