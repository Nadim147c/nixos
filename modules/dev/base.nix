{
  flake.tree.nixos.dev.base-devel = # Shoutout to archlinux
    { pkgs, ... }:
    {
      packages = with pkgs; [
        curl
        gcc
        gnumake
        just
        sd
        skim
        tree
        unzip
        xh
      ];
    };
}
