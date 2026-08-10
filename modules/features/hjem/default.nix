{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib.lists) singleton;
  inherit (config) username;
in
{
  flake.modules.nixos.base = {
    imports = [ inputs.hjem.nixosModules.default ];
    hjem = {
      extraModules = singleton config.flake.modules.hjem.base;
      clobberByDefault = true;
      users."${username}" = {
        directory = "/home/${username}";
      };
    };
  };
}
