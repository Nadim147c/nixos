{
  topiary-nushell,
  pkgs,
  lib,
  ...
}:
{
  vim = {
    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        formatters_by_ft = {
          nu = [ "topiary_nushell" ];
          go = [
            "goimports"
            "gofumpt"
          ];
        };
        formatters = {
          goimports.command = lib.getExe' pkgs.gotools "goimports";
          topiary_nushell = {
            command = lib.getExe topiary-nushell;
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
