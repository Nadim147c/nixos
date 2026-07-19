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
  perSystem = { pkgs, ... }: {
    packages.fd = inputs.wrappers.lib.wrapPackage (
      { config, ... }:
      {
        inherit pkgs;
        package = pkgs.fd;
        addFlag = [ "--hidden" ];
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

  flake.modules.nixos.base = { system, ... }: {
    packages = singleton self.packages.${system}.fd;
  };
}
