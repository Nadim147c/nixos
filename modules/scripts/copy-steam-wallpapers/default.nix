{ lib, ... }:
let
  inherit (lib.lists) singleton;
  name = "copy-steam-wallpapers";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-s, --steam=" = "steam install directory";
      };
      completion = {
        positional = singleton [ "$directory" ];
        flags = {
          steam = [ "$directory" ];
        };
      };
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          fd
          coreutils
        ];
        source = ./copy-steam-wallpapers.nu;
      };
  };
}
