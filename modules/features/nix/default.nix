{ lib, ... }:
{
  flake.modules.nixos.base = {
    nix.settings = {
      eval-cache = true;
      experimental-features = [
        "nix-command"
        "cgroups"
        "flakes"
        "pipe-operators"
      ];
      trusted-users = [
        "root"
        "@build"
        "@wheel"
        "@admin"
      ];
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org"
        "https://nvf.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
      ];

      builders-use-substitutes = true;
      flake-registry = "";
      http-connections = 50;
      show-trace = true;
      use-cgroups = true;
      use-xdg-base-directories = true;
    };
  };
}
