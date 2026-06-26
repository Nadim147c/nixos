{ inputs, lib, ... }:
let
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
          command = getExe inputs.topiary-nushell.packages.${system}.default;
          options = [ "format" ];
          includes = [ "*.nu" ];
        };
      };
    };
  };
}
