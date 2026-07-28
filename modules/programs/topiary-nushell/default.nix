{ inputs, ... }:
let
  inherit (inputs) topiary-nushell tree-sitter-nu;
in
{
  perSystem = { pkgs, ... }: {
    packages.nu-formatter = pkgs.callPackage "${topiary-nushell}/package.nix" {
      inherit tree-sitter-nu;
    };
  };
}
