{
  flake.tree.nixos.gui.picard = { pkgs, ... }: {
    packages = [ pkgs.picard ];
  };
}
