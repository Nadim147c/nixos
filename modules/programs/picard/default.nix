{
  flake.modules.nixos.gui = { pkgs, ... }: {
    packages = [ pkgs.picard ];
  };
}
