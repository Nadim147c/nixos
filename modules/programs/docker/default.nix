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
      preserve.directories = singleton "/var/lib/docker";
      virtualisation.docker = {
        enable = true;
        enableOnBoot = false;
      };
    };
  };
}
