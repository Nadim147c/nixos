{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (inputs) import-tree nvf;
  inherit (lib) singleton mkForce;
  inherit (nvf.lib) neovimConfiguration;
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      nvfConfig = neovimConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit (self'.packages) better-iferr nu-formatter;
          inherit inputs;
        };
        modules = (import-tree ./_config).imports;
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
