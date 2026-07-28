{
  nu-formatter,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe getExe';
in
{
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
        };
        formatters = {
          goimports.command = getExe' pkgs.gotools "goimports";
          sql_formatter.command = getExe pkgs.sql-formatter;
          topiary_nushell = {
            command = getExe nu-formatter;
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
}
