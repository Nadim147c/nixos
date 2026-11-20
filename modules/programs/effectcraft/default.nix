{
  config,
  lib,
  ...
}:
{
  flake.tree.nixos.gui.effectcraft =
    { system, pkgs, ... }:
    let
      inherit (config.flake.flatpak.apps.effectcraft.${system}) url sha256;
      appId = "ai.storyteller.effectcraft";
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
