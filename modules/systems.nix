{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.tree.nixos.base.common =
    { pkgs, ... }:
    {
      _module.args.system = pkgs.stdenv.hostPlatform.system;
    };
}
