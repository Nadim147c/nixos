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
    topiary-nushell
    tree-sitter-nu
    ;
  inherit (lib) toList mkForce;

in
{
  perSystem =
    { pkgs, system, ... }:
    let
      nvfConfig = nvf.lib.neovimConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          topiary-nushell = topiary-nushell.packages.${system}.default.override {
            inherit tree-sitter-nu;
          };
        };
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
      packages = toList self.packages.${system}.neovim;
    };

}
