{ lib, ... }:
let
  inherit (lib) singleton;
  name = "hyprlock-player-info";
in
{
  scripts."${name}" = rec {
    inherit name;
    completion = {
      inherit name;
      completion.positional = [
        [ "$files" ]
        [ "$files" ]
      ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = singleton pkgs.playerctl;
        source = ./hyprlock-player-info.nu;
      };
  };
}
