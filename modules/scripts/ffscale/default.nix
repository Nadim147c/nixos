let
  name = "ffscale";
in
{
  scripts."${name}" = rec {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-c, --scale" = "Scale multiplier (e.g. 2, 1.5, 0.5)";
        "-q, --quality" = "Target height (e.g. 1080, 720)";
        "-s, --size" = "Explicit scale string (e.g. 1920:1080)";
        "-f, --filter" = "Additional ffmpeg filter (e.g. fps=10)";
      };
      completion.positional = [
        [ "$files" ]
        [ "$files" ]
      ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          ffmpeg
          coreutils
        ];
        source = ./ffscale.nu;
      };
  };
}
