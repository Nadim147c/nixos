{ lib, ... }:
let
  inherit (lib) singleton;
in
{
  flake.modules.nixos.hack = { pkgs, ... }: {
    services.tor.enable = true;
    services.tor.client.enable = true;
    packages = singleton pkgs.tor-browser;
  };
}
