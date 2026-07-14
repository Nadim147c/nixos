let
  name = "qs-screenrecord";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      let
        args = {
          inheritPath = true;
          runtimeInputs = builtins.attrValues {
            inherit (pkgs)
              pulseaudio
              ffmpeg
              libnotify
              slurp
              wf-recorder
              ;
          };
        };
      in
      pkgs.writers.writeGoBin name args (builtins.readFile ./qs-screenrecord.go);
  };
}
