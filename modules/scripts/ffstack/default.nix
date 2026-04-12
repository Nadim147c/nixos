_:
let
  name = "ffstack";
in
{
  scripts."${name}" = rec {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-h, --horizontal" = "Use horizontal stack";
        "-v, --vertical" = "Use vertical stack";
        "-e, --extension=" = "The out extension";
        "-s, --margin=" = "The spacing between videos";
        "--debug" = "Enable debug logging";
        "--help" = "Show help usage";
      };
      completion = {
        flag.extension = [
          "mkv"
          "mov"
          "mp4"
          "webm"
          "jpeg"
          "jpg"
          "png"
          "webp"
        ];
        positionalany = [ "$files" ];
      };
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          ffmpeg
          gum
        ];
        source = ./ffstack.nu;
      };
  };
}
