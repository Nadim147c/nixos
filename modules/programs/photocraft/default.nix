{
  config,
  lib,
  ...
}:
{
  flake.tree.nixos.gui.photocraft =
    { system, pkgs, ... }:
    let
      inherit (config.flake.flatpak.apps.photocraft.${system}) url sha256;
      appId = "ai.storyteller.photocraft";
    in
    {
      services.flatpak = {
        packages = lib.singleton {
          inherit appId sha256;
          bundle = toString <| pkgs.fetchurl { inherit url sha256; };
        };
      };
    };
}
