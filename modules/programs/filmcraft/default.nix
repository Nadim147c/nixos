{
  config,
  lib,
  ...
}:
{
  flake.tree.nixos.gui.filmcraft =
    { system, pkgs, ... }:
    let
      inherit (config.flake.flatpak.apps.filmcraft.${system}) url sha256;
      appId = "ai.storyteller.filmcraft";
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
