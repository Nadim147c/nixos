{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  flake.tree.nixos.base.sudo = {
    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = mkForce true;
        execWheelOnly = mkForce true;
        extraConfig = ''
          Defaults lecture="never"
        '';
      };
    };
  };
}
