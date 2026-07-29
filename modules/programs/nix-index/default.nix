{ inputs, lib, ... }:
let
  inherit (lib) singleton;
in
{
  flake.modules.nixos.base = {
    imports = singleton inputs.nix-index-database.nixosModules.default;
    programs.nix-index-database = {
      enable = true;
      comma.enable = true;
    };
  };
}
