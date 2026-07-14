let
  name = "ffcompress";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      let
        args.runtimeInputs = [ pkgs.ffmpeg ];
      in
      pkgs.writers.writeGoBin name args (builtins.readFile ./ffcompress.go);
  };
}
