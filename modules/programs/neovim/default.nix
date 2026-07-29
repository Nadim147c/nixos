{
  config,
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib) singleton mkForce;
  inherit (inputs.nvf.lib) neovimConfiguration;
in
{
  perSystem =
    {
      pkgs,
      system,
      self',
      ...
    }:
    let
      nvfConfig = neovimConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit (self'.packages) better-iferr nu-formatter;
          inherit inputs system;
        };
        modules = attrValues config.flake.modules.neovim;
      };
    in
    {
      packages = { inherit (nvfConfig) neovim; };
    };

  flake.modules.nixos.base = { system, ... }: {
    programs.nano.enable = mkForce false;
    sessionVariables.EDITOR = "nvim";
    packages = singleton self.packages.${system}.neovim;
  };
}
