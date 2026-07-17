{ inputs, lib, ... }:
let
  inherit (inputs) topiary-nushell tree-sitter-nu;
  inherit (lib) genAttrs getExe const;
  enabled.enable = true;
  makeEnabled = l: genAttrs l (const enabled);
in
{
  perSystem = { system, ... }: {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = makeEnabled [
        "nixfmt"
        "gofumpt"
        "shellcheck"
        "shfmt"
        "just"
        "qmlformat"
        "stylua"
        "taplo"
      ];

      settings.formatter = {
        "topiary-nushell" = {
          command = getExe <| topiary-nushell.packages.${system}.default.override { inherit tree-sitter-nu; };
          options = [ "format" ];
          includes = [ "*.nu" ];
        };
      };
    };
  };
}
