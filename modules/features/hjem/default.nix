{
  config,
  inputs,
  ...
}:
let
  inherit (config) username;
in
{
  flake.modules.nixos.base = {
    imports = [ inputs.hjem.nixosModules.default ];
    hjem = {
      clobberByDefault = true;
      users."${username}" = {
        directory = "/home/${username}";
      };
    };
  };
}
