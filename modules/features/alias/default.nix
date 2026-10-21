{ config, lib, ... }:
let
  inherit (lib) mkAliasOptionModule;
in
{
  flake.tree.nixos.base.common = {
    imports = [
      (mkAliasOptionModule [ "packages" ] [ "environment" "systemPackages" ])
      (mkAliasOptionModule [ "sessionVariables" ] [ "environment" "sessionVariables" ])
      (mkAliasOptionModule [ "hj" ] [ "hjem" "users" config.username ])
    ];
  };
}
