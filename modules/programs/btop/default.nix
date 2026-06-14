{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) toList;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.btop = inputs.wrappers.wrappers.btop.wrap {
        inherit pkgs;
        package = pkgs.btop;
        settings = {
          theme_background = false;
          vim_keys = true;
          update_ms = 200;
        };
      };
    };

  flake.modules.nixos.base =
    { system, ... }:
    {
      home.packages = toList self.packages.${system}.btop;
    };
}
