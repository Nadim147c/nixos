{ inputs, lib, ... }:
let
  inherit (lib) singleton;
in
{
  flake.tree.nixos.base.nix-index = {
    imports = singleton inputs.nix-index-database.nixosModules.default;
    programs.nix-index-database = {
      enable = true;
      comma.enable = true;
    };
  };
}
