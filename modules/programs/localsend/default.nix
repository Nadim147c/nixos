{ lib, ... }:
let
  inherit (lib.lists) singleton;
in
{
  flake.tree.nixos.gui.localsend = { pkgs, ... }: {
    packages = singleton pkgs.localsend;
  };
}
