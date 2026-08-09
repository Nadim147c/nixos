{ inputs, lib, ... }:
let
  inherit (inputs) fast-nix-gc;
  inherit (lib) singleton;
in
{
  flake.modules.nixos.base = { system, ... }: {
    imports = singleton fast-nix-gc.nixosModules.default;
    packages = singleton fast-nix-gc.packages.${system}.default;
    services.fast-nix-gc = {
      enable = true;
      automatic = true;
      dates = "weekly";
      deleteOlderThan = "30d";
      keepRecent = "7d";
      ensureFree = "50G";
    };
    services.fast-nix-optimise = {
      enable = false; # The extra CPU usages not the disk space.
      automatic = true;
      dates = "weekly";
    };
  };
}
