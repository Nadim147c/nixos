{
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      _module.args.system = pkgs.stdenv.hostPlatform.system;
    };
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      _module.args.system = pkgs.stdenv.hostPlatform.system;
    };
}
