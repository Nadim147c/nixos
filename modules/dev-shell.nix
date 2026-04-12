{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      inherit (inputs.gomod2nix.legacyPackages.${system}) mkGoEnv gomod2nix;
      goEnv = mkGoEnv { pwd = ../.; };
    in
    {
      devShells.default = pkgs.mkShell {
        name = "nixos";
        buildInputs = with pkgs; [
          goEnv
          gomod2nix
          inputs.topiary-nushell.packages.${system}.default
          lua-language-server
          nh
          nix-fast-build
          nixd
          nixfmt
          stylua
          statix
        ];
      };
    };
}
