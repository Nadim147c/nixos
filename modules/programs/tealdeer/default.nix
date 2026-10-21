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
    { pkgs, self', ... }:
    {
      packages.tldr = self'.packages.tealdeer;
      packages.tealdeer = inputs.wrappers.wrappers.tealdeer.wrap {
        inherit pkgs;
        package = pkgs.tealdeer;
        settings.updates = {
          auto_update = true;
          auto_update_interval_hours = 100;
        };
      };
    };

  flake.tree.nixos.base.tldr = { system, ... }: {
    packages = singleton self.packages.${system}.tealdeer;
  };
}
