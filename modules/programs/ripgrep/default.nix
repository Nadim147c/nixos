{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) singleton;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.ripgrep = inputs.wrappers.lib.wrapPackage (
        { config, ... }:
        {
          inherit pkgs;
          package = pkgs.ripgrep;
          addFlag = singleton "--hidden";
          flags."--ignore-file" = config.constructFiles.renderedSettings.path;
          flagSeparator = "=";
          constructFiles.renderedSettings = {
            relPath = "${config.binName}-ignore";
            content = ''
              .git/
              .jj/
              *.bak
            '';
          };
        }
      );
    };

  flake.tree.nixos.base.ripgrep = { system, ... }: {
    packages = singleton self.packages.${system}.ripgrep;
  };
}
