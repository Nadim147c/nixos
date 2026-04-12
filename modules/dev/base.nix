{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        curl
        gcc
        gnumake
        just
        neovim
        sd
        skim
        tree
        unzip
        xh
      ];
    };
}
