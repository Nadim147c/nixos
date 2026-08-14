{ self, lib, ... }:
let
  inherit (lib) getExe getExe';
in
{
  flake.modules.neovim.base = { pkgs, system, ... }: {
    vim = {
      formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            nu = [ "topiary_nushell" ];
            sql = [ "sql_formatter" ];
            go = [
              "goimports"
              "gofumpt"
            ];
            nim = [ "nph" ];
          };
          formatters = {
            goimports.command = getExe' pkgs.gotools "goimports";
            sql_formatter.command = getExe pkgs.sql-formatter;
            nph.command = getExe pkgs.nph;
            topiary_nushell = {
              command = getExe self.packages.${system}.nu-formatter;
              args = [
                "format"
                "--language"
                "nu"
              ];
            };
          };
        };
      };
    };
  };
}
