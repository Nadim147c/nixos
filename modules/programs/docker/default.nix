{ lib, ... }:
{
  flake.modules.nixos.dev = {
    virtualisation.docker.enable = true;
  };
  flake.modules.nixos.server = {
    virtualisation.docker.enable = true;
  };
}
