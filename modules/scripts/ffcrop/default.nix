_:
let
  name = "ffcrop";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-t, --detection-time=" = "Number of seconds to detect the video for crop";
        "--top=" = "Number of pixel to add to the top after calculating the crop";
        "--bottom=" = "Number of pixel to add to the bottom after calculating the crop";
        "--right=" = "Number of pixel to add to the right after calculating the crop";
        "--left=" = "Number of pixel to add to the left after calculating the crop";
        "--around=" = "Number of pixel to add to the around after calculating the crop";
        "--threads=" = "Number of threads to use when transcoding";
        "--ratio=" = "Use a ratio instead of auto detect to crop. (ex: 1.5, 1/2, 18x9, 16:9)";
        "--white" = "Auto detect white bar instead of black to crop";
        "--preview" = "Show a preview of the crop instead of outputting it";
        "--debug" = "Enable debug logging";
      };
      completion.positionalany = [ "$files" ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          ffmpeg
          gum
        ];
        inheritPath = false;
        source = ./ffcrop.nu;
      };
  };
}
