let
  name = "qs-ffmpeg-compress-progress";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          ffmpeg
        ];
        source = ./qs-ffmpeg-compress-progress.nu;
      };
  };
}
