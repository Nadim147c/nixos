{
  flake.modules.nixos.hack =
    { pkgs, ... }:
    {
      services.tor.enable = true;
      services.tor.client.enable = true;
      packages = [ pkgs.tor-browser ];
    };
}
