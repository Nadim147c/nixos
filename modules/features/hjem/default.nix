{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) toList;
  inherit (config) username;
in
{
  flake.modules.nixos.base = {
    imports = [ inputs.hjem.nixosModules.default ];
    hjem = {
      extraModules = toList inputs.hjem-rum.hjemModules.default;
      clobberByDefault = true;
      users."${username}" = {
        directory = "/home/${username}";
      };
    };
  };
}
