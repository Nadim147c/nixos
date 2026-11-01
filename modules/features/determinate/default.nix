{ inputs, lib, ... }:
let
  inherit (lib.lists) singleton;
in
{
  flake.tree.nixos.base.determinate = {
    imports = singleton inputs.determinate.nixosModules.default;
  };
}
