{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (inputs)
    import-tree
    nvf
    tree-sitter-nu
    ;
  inherit (lib) singleton mkForce;
  inherit (nvf.lib) neovimConfiguration;

in
{
  perSystem =
    { pkgs, ... }:
    let
      topiary-nushell = inputs.topiary-nushell.packages.${pkgs.system}.default.override {
        inherit tree-sitter-nu;
      };
      nvfConfig = neovimConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs topiary-nushell; };
        modules = (import-tree ./_config).imports;
      };
    in
    {
      packages = { inherit (nvfConfig) neovim; };
    };

  flake.modules.nixos.base =
    { system, ... }:
    {
      programs.nano.enable = mkForce false;
      sessionVariables.EDITOR = "nvim";
      packages = singleton self.packages.${system}.neovim;
    };

}
