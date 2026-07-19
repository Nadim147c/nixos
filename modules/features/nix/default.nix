{ lib, ... }:
let
  inherit (lib) singleton;

in
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
      substituters = singleton "https://cache.nixos.org/";
      trusted-public-keys = singleton "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";

      builders-use-substitutes = true;
      flake-registry = "";
      http-connections = 50;
      show-trace = true;
      use-cgroups = true;
      use-xdg-base-directories = true;
    };
  };
}
