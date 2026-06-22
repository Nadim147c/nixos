{ self, lib, ... }:
let
  inherit (lib) toList;
in
{
  flake.modules.nixos.hack =
    { system, ... }:
    {
      packages = toList self.packages.${system}.morphe-cli;
    };
}
