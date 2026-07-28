{
  perSystem =
    { pkgs, self', ... }:
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
          inherit (self'.packages) nu-formatter;
        };
      };
    };
}
