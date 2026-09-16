{ self, ... }:
let
  name = "qs-open-music-player";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = [
          pkgs.dbus
          self.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
        ];
        source = ./qs-open-music-player.nu;
      };
  };
}
