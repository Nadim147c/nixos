{ config, ... }:
{
  flake.tree.nixos.dev.docker = {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };
  };
}
