_:
let
  options =
    { lib, pkgs, ... }:
    {
      nix = {
        package = lib.mkForce pkgs.nixVersions.latest;
        settings = {
          eval-cache = true;
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
          warn-dirty = false;
          substituters = [
            "https://cache.nixos.org/"
            "https://hyprland.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          ];
        };
      };
    };
in
{
  flake.modules.nixos.base = options;
  flake.modules.homeManager.base = options;
}
