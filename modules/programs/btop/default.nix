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

  flake.tree.nixos.base.btop = { system, ... }: {
    packages = singleton self.packages.${system}.btop;
  };
}
