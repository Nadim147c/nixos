{ inputs, ... }:
let
  inherit (inputs) topiary-nushell tree-sitter-nu;
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      nu-formatter = topiary-nushell.packages.${system}.default.override {
        inherit tree-sitter-nu;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        name = "nixos";
        buildInputs = builtins.attrValues {
          inherit (pkgs)
            lua-language-server
            nh
            nix-fast-build
            nixd
            nixfmt
            stylua
            statix
            ;
          inherit nu-formatter;
        };
      };
    };
}
