{ lib, ... }:
let
  inherit (lib) singleton;
  name = "convert-to-opus";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      completion.positionalany = singleton [ "$files" ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          magika-cli
          ffmpeg
        ];
        source = ./convert-to-opus.nu;
      };
  };
}
