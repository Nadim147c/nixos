{

  flake.modules.nixos.gui = { pkgs, ... }: {
    packages = [
      pkgs.kopuz
      pkgs.picard
      pkgs.nicotine-plus
      pkgs.lrcget
    ];
  };
}
