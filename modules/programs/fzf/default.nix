{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) singleton getExe;
in
{
  perSystem =
    { self', pkgs, ... }:
    {
      packages.fzf = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.fzf;
        envDefault = {
          FZF_DEFAULT_COMMAND = "${getExe self'.packages.fd} --color=always";
          FZF_DEFAULT_OPTS = ''
            --border
            --ansi
            --layout=reverse
          '';
        };
      };
    };

  flake.modules.nixos.base = { system, ... }: {
    packages = singleton self.packages.${system}.fzf;
  };
}
