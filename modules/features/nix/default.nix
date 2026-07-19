{ inputs, lib, ... }:
let
  inherit (lib) singleton;

in
{
  flake.modules.nixos.base = {
    imports = [ inputs.ncro.nixosModules.default ];

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
      substituters = singleton "http://localhost:6767";

      builders-use-substitutes = true;
      flake-registry = "";
      http-connections = 50;
      show-trace = true;
      use-cgroups = true;
      use-xdg-base-directories = true;
    };

    services.ncro = {
      enable = true;
      addUpstreamPublicKeys = true;
      settings = {
        logging.level = "info";
        server = {
          listen = ":6767";
          cache_priority = 20;
        };
        upstreams =
          let
            makeUpstream = url: public_key: { inherit url public_key; };
          in
          [
            (makeUpstream "https://cache.nixos.org" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=")
            (makeUpstream "https://nix-community.cachix.org" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=")
            (makeUpstream "https://nvf.cachix.org" "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI=")
          ];
      };
    };
  };
}
