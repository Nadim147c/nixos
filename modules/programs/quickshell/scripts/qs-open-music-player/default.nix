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
        runtimeInputs = with pkgs; [
          dbus
          hyprland
        ];
        source = ./qs-open-music-player.nu;
      };
  };
}
