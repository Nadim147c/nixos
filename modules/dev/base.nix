{
  flake.modules.nixos.dev =
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
