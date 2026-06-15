{
  flake.modules.nixos.hacking =
    { pkgs, ... }:
    {
      services.tor.enable = true;
      services.tor.client.enable = true;
      packages = [ pkgs.tor-browser ];
    };
}
