{ lib, ... }:
let
  inherit (lib) genAttrs getExe const;

  enabled.enable = true;
  makeEnabled = names: genAttrs names (const enabled);
in
{
  perSystem = { self', ... }: {
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

      settings = {
        excludes = [ "vendor/*" ];
        formatter = {
          "topiary-nushell" = {
            command = getExe self'.packages.nu-formatter;
            options = [ "format" ];
            includes = [ "*.nu" ];
          };
        };
      };
    };
  };
}
