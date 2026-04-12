let
  name = "mpvpaper-daemon";
in
{
  scripts."${name}" = rec {
    inherit name;
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./mpvpaper-daemon.go);
  };
}
