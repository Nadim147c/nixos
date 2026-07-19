{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      _module.args.system = pkgs.stdenv.hostPlatform.system;
    };
}
