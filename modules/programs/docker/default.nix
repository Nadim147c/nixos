{ config, lib, ... }:
let
  inherit (lib) singleton;
  inherit (config.flake.modules.nixos) containerization;
in
{
  flake.modules.nixos = {
    dev.imports = singleton containerization;
    server.imports = singleton containerization;
    containerization = {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = false;
      };
    };
  };
}
