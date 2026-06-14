{ config, ... }:
{
  flake.modules.nixos.base =
    { lib, ... }:
    let
      inherit (lib) mkAliasOptionModule;
    in
    {
      imports = [
        (mkAliasOptionModule [ "packages" ] [ "environment" "systemPackages" ])
        (mkAliasOptionModule [ "sessionVariables" ] [ "environment" "sessionVariables" ])
        (mkAliasOptionModule [ "home" ] [ "hjem" "users" config.username ])
      ];
    };

}
