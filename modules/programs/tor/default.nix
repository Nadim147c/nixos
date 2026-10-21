{ lib, ... }:
let
  inherit (lib) singleton;
in
{
  flake.tree.nixos.hack.tor-browser = { pkgs, ... }: {
    packages = singleton pkgs.tor-browser;
  };
}
