{ inputs, ... }:
{
  perSystem =
    {
      lib,
      system,
      ...
    }:
    {
      treefmt = {
        projectRootFile = "flake.nix";

        programs = {
          nixfmt.enable = true;
          gofumpt.enable = true;
          shellcheck.enable = true;
          shfmt.enable = true;
          just.enable = true;
          qmlformat.enable = true;
        };

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
