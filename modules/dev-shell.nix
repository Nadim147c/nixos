{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos";
        nativeBuildInputs = builtins.attrValues {
          inherit (pkgs)
            lua-language-server
            nh
            nix-fast-build
            nixd
            nixfmt
            stylua
            statix
            fortune
            pkg-config
            ;
          inherit (pkgs.qt6) qtshadertools;
          inherit (self'.packages) nu-formatter;
        };
        buildinputs = [ pkgs.glib ];
      };
    };
}
