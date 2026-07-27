{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          name = "real";
          buildInputs = with pkgs; [
            go # we need go of course

            gofumpt # formater
            golines # line formater
            gopls # the language server
            revive # linter
            gotestsum # test runner

            just # task runner
            just-lsp # task runner lsp
          ];
        };

      });
    };
}
