{ inputs, ... }:
{
  perSystem =
    {
      lib,
      system,
      ...
    }:
    let
      enabled.enable = true;
    in
    {
      treefmt = {
        projectRootFile = "flake.nix";

        programs = lib.genAttrs [
          "nixfmt"
          "gofumpt"
          "shellcheck"
          "shfmt"
          "just"
          "qmlformat"
          "stylua"
          "taplo"
        ] (_: enabled);

        settings.formatter = {
          "topiary-nushell" = {
            command = lib.getExe inputs.topiary-nushell.packages.${system}.default;
            options = [ "format" ];
            includes = [ "*.nu" ];
          };
        };
      };
    };
}
