{ self, ... }:
let
  name = "qs-wallpaper-list";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:

      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = [ self.packages.${pkgs.stdenv.hostPlatform.system}.xdg-base-dir ];
        source = ./qs-wallpaper-list.nu;
      };
  };
}
