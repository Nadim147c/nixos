{
  config,
  inputs,
  ...
}:
let
  inherit (config) username;
in
{
  flake.tree.nixos.base.common = {
    imports = [ inputs.hjem.nixosModules.default ];
    hjem = {
      clobberByDefault = true;
      users."${username}" = {
        directory = "/home/${username}";
      };
    };
  };
}
