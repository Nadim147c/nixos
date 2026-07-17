{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  flake.modules.nixos.base = {
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
