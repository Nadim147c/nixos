{ self, lib, ... }:
let
  inherit (lib) toList;
in
{
  flake.tree.nixos.hack.morphe = { system, ... }: {
    packages = toList self.packages.${system}.morphe-desktop;
  };
}
