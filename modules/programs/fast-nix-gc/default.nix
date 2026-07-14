{ inputs, lib, ... }:
let
  inherit (lib) toList;
in
{
  flake.modules.nixos.base = { system, ... }: {
    imports = [ inputs.fast-nix-gc.nixosModules.default ];
    packages = toList inputs.fast-nix-gc.packages.${system}.default;
    services.fast-nix-gc = {
      enable = true;
      automatic = true;
      dates = "weekly";
      deleteOlderThan = "30d";
      keepRecent = "7d";
      ensureFree = "50G";
    };
    services.fast-nix-optimise = {
      enable = true;
      automatic = true;
      dates = "weekly";
    };
  };
}
