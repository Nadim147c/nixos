{ config, lib, ... }:
let
  inherit (lib) toList;
  inherit (config.flake.modules.nixos) containerization;
in
{
  flake.modules.nixos = {
    dev.imports = toList containerization;
    server.imports = toList containerization;
    containerization = {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
      };
    };
  };
}
