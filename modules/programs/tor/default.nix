{ lib, ... }:
let
  inherit (lib) singleton;
in
{
  flake.tree.nixos.hack.tor-browser = { pkgs, ... }: {
    packages = singleton pkgs.tor-browser;
    services.tor.enable = true;
    services.tor.client.enable = true;
    services.tor.settings = {
      SOCKSPort = [ 9150 ];
    };
  };
}
