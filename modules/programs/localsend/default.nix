{ lib, ... }:
let
  inherit (lib.lists) singleton;
in
{
  flake.modules.nixos.gui = { pkgs, ... }: {
    packages = singleton pkgs.localsend;
  };
}
