{
  self,
  lib,
  ...
}:
let
  inherit (lib) toList;
in
{
  perSystem = { pkgs, ... }: {
    packages.waybar-lyric-impure = pkgs.impurify pkgs.waybar-lyric;
  };

  flake.modules.nixos.gui = { system, ... }: {
    packages = toList self.packages.${system}.waybar-lyric-impure;
  };
}
