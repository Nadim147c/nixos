{ config, lib, ... }:
let
  inherit (lib) mkAliasOptionModule;
in
{
  flake.modules.nixos.base = {
    imports = [
      (mkAliasOptionModule [ "packages" ] [ "environment" "systemPackages" ])
      (mkAliasOptionModule [ "sessionVariables" ] [ "environment" "sessionVariables" ])
      (mkAliasOptionModule [ "home" ] [ "hjem" "users" config.username ])
      (mkAliasOptionModule [ "preserve" ] [ "preservation" "preserveAt" "/persistent" ])
      (mkAliasOptionModule
        [ "preserveHome" ]
        [ "preservation" "preserveAt" "/persistent" "users" config.username ]
      )
    ];
  };

}
